# dev-volumes

`dev.sh` starts a disposable, feature-mounted dev container in the current
directory. For projects that already have a `compose.yaml`, `dev-compose.yaml`
in this repo is a drop-in overlay that adds a dev container to the project's
services.

## developing with docker compose

copy `dev-compose.yaml` next to your project's `compose.yaml`, adjust the
feature volumes to the features you want (same images and versions as
`dev.sh --feature`), then:

```
# interactive dev shell (project services must be started separately
# unless dev declares depends_on):
docker compose -f dev-compose.yaml run --rm dev

# or everything in the background, then exec in:
docker compose -f dev-compose.yaml up -d
docker compose -f dev-compose.yaml exec dev bash
```

the dev image's entrypoint and `.bashrc` share the same environment setup
(`dev/env.sh`), so both entry paths get the feature `bin/` directories on
`PATH` and the compose plugin linked — `exec` bypasses the entrypoint, but
interactive bash sources `.bashrc`.

notes:

- requires Docker Compose v2.35+ (`type: image` volumes)
- for the `docker` feature, pass the host socket's gid explicitly:
  `DOCKER_GID=$(stat -c %g /var/run/docker.sock) docker compose -f dev-compose.yaml run --rm dev`

## installing tmux

since the tmux version running in the dev volumes must be close to the one running on your host system it is recommended that you install the statically linked tmux binary from the tmux dev volumes instead of your package managers version:

```
docker rm -f dummy
docker create --name dummy \
  ghcr.io/erikbergsten/dev-volumes/tmux:latest dummy-command
docker cp dummy:/bin/tmux <YOUR_TMUX_BINARY_PATH>
docker rm dummy
```
