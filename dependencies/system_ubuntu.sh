system.ubuntu.package.add-apt-repository() {
  system.package software-properties-common
}

system.ubuntu.repository.official() {
  local _official_repository=$1; shift
  # Adds the universe repository
  # TODO: Add a "-d" flag or something that removes the repository
  #   instead of just adding it
  requires system.ubuntu.package.add-apt-repository
  __babashka_log "== ${FUNCNAME[0]} ${_official_repository}"
  function get_id() {
    echo "${_official_repository}"
  }
  function is_met() {
    grep -rhE ^deb /etc/apt/sources.list* \
      | grep "ubuntu" \
      | grep -v "^#" \
      | grep "$(lsb_release -cs) " \
      | grep -q ${_official_repository}
    return $?
  }
  function meet() {
    $__babashka_sudo add-apt-repository -y ${_official_repository}
    $__babashka_sudo apt-get -y update
  }
  process
}
