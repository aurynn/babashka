docker.install() {
  system.package docker
  system.package docker-cli-compose
  system.package skopeo
  system.package jq
}
docker.prerequisites.skopeo() {
  system.package skopeo
}
