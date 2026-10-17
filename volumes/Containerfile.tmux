# Official statically linked tmux from tmux/tmux-builds as of 2026-10-17: 3.7c.
# Pinned to the same version as the host so the shared /tmp/tmux-1000 socket
# never mixes client/server protocol versions.
arg TMUX_VERSION=3.7c

from ghcr.io/erikbergsten/dev-volumes/builder:0.1.0 as build-arm64
arg TMUX_VERSION

run curl -fL --retry 3 -o /tmp/tmux.tar.gz "https://github.com/tmux/tmux-builds/releases/download/v${TMUX_VERSION}/tmux-${TMUX_VERSION}-linux-arm64.tar.gz"
run printf '%s  %s\n' '29dcb978da2a4b0cf6790f9e004865dac239a3ba03bbf776dddacce23d03831b' /tmp/tmux.tar.gz | sha256sum -c -
run mkdir -p /build/tmux/bin && tar -xzf /tmp/tmux.tar.gz -C /build/tmux/bin
run chmod +x /build/tmux/bin/tmux && /build/tmux/bin/tmux -V

from ghcr.io/erikbergsten/dev-volumes/builder:0.1.0 as build-amd64
arg TMUX_VERSION

run curl -fL --retry 3 -o /tmp/tmux.tar.gz "https://github.com/tmux/tmux-builds/releases/download/v${TMUX_VERSION}/tmux-${TMUX_VERSION}-linux-x86_64.tar.gz"
run printf '%s  %s\n' 'cc56bd1cc873eb6089c615f0496b072385bda8a6d944069f38564a5d49c128aa' /tmp/tmux.tar.gz | sha256sum -c -
run mkdir -p /build/tmux/bin && tar -xzf /tmp/tmux.tar.gz -C /build/tmux/bin
run chmod +x /build/tmux/bin/tmux && /build/tmux/bin/tmux -V

arg TARGETARCH
from build-${TARGETARCH} as build

from scratch
copy --from=build /build/tmux/bin/ /bin/
