postgres.repo() {
  local ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  arch=$(dpkg --print-architecture)
  # Set up the repo
  system.debian.repo.custom pgdg \
    -k https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    -u http://apt.postgresql.org/pub/repos/apt/ \
    -d "$(lsb_release -cs)-pgdg" \
    -a $arch \
    -c main

  # Pin the pgdg packages over the system-provided packages
  system.file /etc/apt/preferences.d/pgdg.pref \
    -o root \
    -g root \
    -m 644 \
    -s ${ABSOLUTE_PATH}/files/etc/apt/preferences.d/pgdg.pref
}

postgres.install() {
  local _version=$1; shift

  requires postgres.repo
  system.package postgresql-${_version}
}
