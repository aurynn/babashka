docker.install() {
  system.package docker
  system.package skopeo
  system.package jq
  system.systemd.enable docker
  systemctl start docker
}

docker-compose.install() {
  # just acts as a CLI plugin instead
  # so that's easy enough to use
  # https://github.com/docker/compose/releases/download/v2.1.1/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)
  requires docker.install
  system.package docker-compose
  
  
}
