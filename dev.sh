#!/usr/bin/env bash

features=()
passthrough=()
supported_features=(node docker opencode kubectl python)

add_feature() {
  local feature=$1
  local supported

  for supported in "${supported_features[@]}"; do
    if [[ "$feature" == "$supported" ]]; then
      features+=("$feature")
      return 0
    fi
  done

  printf 'Unsupported feature: %s\nSupported features: %s\n' \
    "$feature" "${supported_features[*]}" >&2
  exit 2
}

while (($#)); do
  case "$1" in
    -f|--feature)
      if (($# < 2)); then
        printf 'Missing value for --feature\n' >&2
        exit 1
      fi
      add_feature "$2"
      shift 2
      ;;
    --feature=*)
      add_feature "${1#*=}"
      shift
      ;;
    --)
      shift
      passthrough+=("$@")
      break
      ;;
    *)
      # Keep all non-feature arguments, including unknown options and values.
      passthrough+=("$1")
      shift
      ;;
  esac
done

# Replace the script's positional parameters with the pass-through arguments.
set -- "${passthrough[@]}"

registry=ghcr.io/erikbergsten/dev-volumes

dev_image=dev:latest
node_version=latest
kubectl_version=latest
docker_version=latest
opencode_version=latest

get_version() {
  name="$1_version"
  echo -n ${!name}
}

get_mount() {
  feature=$1
  version=$(get_version $feature)
  echo "--mount type=image,source=$registry/$feature:$version,destination=/opt/$feature"
}

dockersupport="--mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock --group-add $(stat -c '%g' "/var/run/docker.sock")"

kubectlsupport="--mount type=bind,src=$KUBECONFIG,dst=/opt/kubeconfig.yaml -e KUBECONFIG=/opt/kubeconfig.yaml"
cmd="docker run -it --rm -v $PWD:/work -w /work"

printf 'Features (%d):\n' "${#features[@]}"
for feature in "${features[@]}"; do
  if [[ "$feature" == "docker" ]]; then
    cmd+=" $dockersupport"
  elif [[ "$feature" == "kubectl" ]]; then
    cmd+=" $kubectlsupport"
  fi
  mount=$(get_mount $feature)
  cmd+="  $mount"
done

cmd="$cmd $@ $registry/$dev_image"

$cmd
