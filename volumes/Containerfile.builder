# volume:builder
from debian:latest

run apt update -y
run apt install -y curl bash git xz-utils

workdir /build

entrypoint ["bash"]
