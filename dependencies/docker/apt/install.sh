docker.packages() {
  system.package apt-transport-https
  system.package ca-certificates
  system.package curl
  system.package software-properties-common
  system.package gnupg
  # JQ allows for json parsing later, which we need
  system.package jq
}

docker.repo() {
  
  # get our system type
  # and our architecture
  system_type=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
  arch=$(dpkg --print-architecture)
  
  system.debian.repo.custom docker \
    -k https://download.docker.com/linux/$system_type/gpg \
    -u https://download.docker.com/linux/$system_type \
    -a $arch \
    -c stable
}

docker.dns.enable() {
  local ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  system.directory /etc/systemd/resolved.conf.d \
    -m 0755 \
    -o root \
    -g root

  system.file /etc/systemd/resolved.conf.d/docker.conf \
    -s ${ABSOLUTE_PATH}/files/etc/systemd/resolved.conf.d/docker.conf

  systemctl restart systemd-resolved
}

docker.install() {
  requires docker.packages
  requires docker.repo
  system.package containerd.io
  system.package docker-ce
  system.package docker-ce-cli
  requires docker.prerequisites.skopeo
  # requires system.debian.packages.support
}

docker-compose.install() {
  # just acts as a CLI plugin instead
  # so that's easy enough to use
  # https://github.com/docker/compose/releases/download/v2.1.1/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)
  requires docker.install
  system.package docker-compose-plugin
}
