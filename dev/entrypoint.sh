#!/bin/bash
# 1. Enable nullglob so if no matches exist, the loop evaluates to nothing
shopt -s nullglob

# 2. Safely loop through matches and append them to PATH
for d in /opt/*/bin/; do
    # Strip the trailing slash and append
    PATH="$PATH:${d%/}"
done

# 3. The docker CLI does not discover plugins (e.g. `docker compose`) on PATH,
#    only in its cli-plugins directories. Link any feature image's compose
#    binary into the user's, which is the first directory searched.
plugin_dir="$HOME/.docker/cli-plugins"
mkdir -p "$plugin_dir"
for p in /opt/*/bin/docker-compose; do
    ln -sf "$p" "$plugin_dir/docker-compose"
done

# 4. Disable nullglob to return shell behavior to normal
shopt -u nullglob

# 5. Hand control over to whatever command was requested (e.g., bash)
exec "$@"
