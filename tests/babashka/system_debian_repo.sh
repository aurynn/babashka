system.debian.repo.docker() {
  system.debian.repo.custom docker \
    -k https://download.docker.com/linux/ubuntu/gpg \
    -u https://download.docker.com/linux/ubuntu \
    -a amd64 \
    -c stable
}

system_debian_repo_custom_distribution() {
  system.debian.repo.custom pgdg \
    -k https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    -u http://apt.postgresql.org/pub/repos/apt/ \
    -d "$(lsb_release -cs)-pgdg" \
    -a amd64 \
    -c main
}
