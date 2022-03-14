docker.volume.present() {
  local _volume=$1; shift
  __babashka_log "${FUNCNAME[0]} $_volume"
  # this needs to verify that Docker is, in fact, installed
  if ! [[ -e /usr/bin/docker ]] && ! [[ -x /usr/bin/docker ]]; then
    # Error out, because we don't have Docker installed
    __babashka_fail "Docker is not installed"
  fi

  function is_met() {
    HASH=$($__babashka_sudo /usr/bin/docker volume ls -q -f "name=${_volume}")
    if [[ "$HASH " == " " ]]; then
      return 1
    fi
    return 0
  }
  function meet() {
    $__babashka_sudo /usr/bin/docker volume create ${_volume}
  }
  process
}

docker.volume.absent() {
  local _volume=$1; shift
  __babashka_log "${FUNCNAME[0]} $_volume"
  # this needs to verify that Docker is, in fact, installed
  if ! [[ -e /usr/bin/docker ]] && ! [[ -x /usr/bin/docker ]]; then
    # Error out, because we don't have Docker installed
    __babashka_fail "Docker is not installed"
  fi

  function is_met() {
    HASH=$($__babashka_sudo /usr/bin/docker volume ls -q -f "name=${_volume}")
    if [[ "$HASH " != " " ]]; then
      return 1
    fi
    return 0
  }
  function meet() {
    $__babashka_sudo /usr/bin/docker volume rm ${_volume}
  }
  process
}
