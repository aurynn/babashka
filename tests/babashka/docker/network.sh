docker_network() {
  docker.network.present "test_network"
  docker.network.absent "test_network"
}
