# Match the environment the entrypoint sets up, so sessions started with
# `docker compose exec` / `docker exec` (which bypass the entrypoint) are
# configured identically.
source /usr/local/lib/dev-env.sh

export PS1='(\033[0;31mdevcontainer\033[0m) [\033[0;32m$(date +%H:%M:%S)\033[0m] \033[0;34m\u\033[0m \w\n$ '
