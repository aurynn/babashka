# Installs Docker
# Assumes an Ubuntu system, obviously
docker.packages() {
  system.package apt-transport-https
  system.package ca-certificates
  system.package curl
  system.package software-properties-common
  system.package gnupg
  # JQ allows for json parsing later, which we will need
  system.package jq
}
docker.repo() {
  system.debian.repo.custom docker \
    -k https://download.docker.com/linux/ubuntu/gpg \
    -u https://download.docker.com/linux/ubuntu \
    -a amd64 \
    -c stable
}

docker.install() {
  requires docker.packages
  requires docker.repo
  system.package containerd.io
  system.package docker-ce
  system.package docker-ce-cli
}
