#!/bin/bash
# 1. Enable nullglob so if no matches exist, the loop evaluates to nothing
shopt -s nullglob

# 2. Safely loop through matches and append them to PATH
for d in /opt/*/bin/; do
    # Strip the trailing slash and append
    PATH="$PATH:${d%/}"
done

# 3. Disable nullglob to return shell behavior to normal
shopt -u nullglob

# 2. Hand control over to whatever command was requested (e.g., bash)
exec "$@"
