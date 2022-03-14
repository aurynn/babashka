docker_volume() {
  docker.volume.present "test_volume"
  docker.volume.absent "test_volume"
}
