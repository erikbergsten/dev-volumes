## installing tmux

since the tmux version running in the dev volumes must be close to the one running on your host system it is recommended that you install the statically linked tmux binary from the tmux dev volumes instead of your package managers version:

```
docker rm -f dummy
docker create --name dummy \
  ghcr.io/erikbergsten/dev-volumes/tmux:latest dummy-command
docker cp dummy:/bin/tmux <YOUR_TMUX_BINARY_PATH>
docker rm dummy
```
