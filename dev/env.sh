# Shared environment setup for the dev container.
#
# Sourced by both the image entrypoint and .bashrc so that interactive
# sessions started via `docker compose exec` (which bypass the entrypoint)
# get the same configuration as entrypoint-launched commands.
#
# Idempotent: safe to source any number of times (nested shells, entrypoint
# followed by an interactive shell).

# Enable nullglob so if no /opt feature volumes are mounted, the loops below
# evaluate to nothing instead of a literal glob pattern.
shopt -s nullglob

# Add every feature volume's bin directory (mounted at /opt/<feature>/bin)
# to PATH, skipping directories that are already present.
for d in /opt/*/bin/; do
    dir=${d%/}
    case ":$PATH:" in
        *":$dir:"*) ;;
        *) PATH="$PATH:$dir" ;;
    esac
done
export PATH

# The docker CLI does not discover plugins (e.g. `docker compose`) on PATH,
# only in its cli-plugins directories. Link any feature image's compose
# binary into the user's, which is the first directory searched.
plugin_dir="$HOME/.docker/cli-plugins"
mkdir -p "$plugin_dir"
for p in /opt/*/bin/docker-compose; do
    ln -sf "$p" "$plugin_dir/docker-compose"
done

shopt -u nullglob
