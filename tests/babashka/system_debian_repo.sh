system.debian.repo.docker() {
  system.debian.repo docker \
    -k https://download.docker.com/linux/ubuntu/gpg \
    -u https://download.docker.com/linux/ubuntu \
    -a amd64 \
    -c stable
}
