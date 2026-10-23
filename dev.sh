#!/usr/bin/env bash

features=()
passthrough=()
debug=0
supported_features=(node docker opencode kubectl python pnpm vibe tmux)

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
    --debug)
      debug=1
      shift
      ;;
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

dev_image=dev:0.2.0
node_version=24.21.0
pnpm_version=12.14.0
python_version=3.14.8
docker_version=29.8.2
kubectl_version=1.37.1
opencode_version=1.19.3
vibe_version=3.0.2
tmux_version=3.7c

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

vibesupport="-e MISTRAL_API_KEY=$MISTRAL_API_KEY"

tmuxsupport="--mount type=bind,src=/tmp/tmux-$(id -u),dst=/tmp/tmux-1000"
cmd="docker run -it --rm -v $PWD:/work -w /work"

if ((!debug)); then
  printf 'Features (%d) - %s\n' "${#features[@]}" "${features[*]}"
fi
for feature in "${features[@]}"; do
  if [[ "$feature" == "docker" ]]; then
    cmd+=" $dockersupport"
  elif [[ "$feature" == "kubectl" ]]; then
    # Only bind the kubeconfig when KUBECONFIG is set; the mount would
    # otherwise fail with an empty source path.
    if [[ -n "${KUBECONFIG:-}" ]]; then
      cmd+=" $kubectlsupport"
    fi
  elif [[ "$feature" == "vibe" ]]; then
    cmd+=" $vibesupport"
  elif [[ "$feature" == "tmux" ]]; then
    # --mount type=bind fails if the source is missing, so create it first
    mkdir -p "/tmp/tmux-$(id -u)"
    cmd+=" $tmuxsupport"
  fi
  mount=$(get_mount $feature)
  cmd+="  $mount"
done

cmd="$cmd $@ $registry/$dev_image"

if ((debug)); then
  printf '%s\n' "$cmd"
else
  $cmd
fi
