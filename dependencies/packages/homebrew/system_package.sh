system.package.brew() {
  local _package_name=$1; shift
  
  # Any flags you want to set should be set via apt_flags= outside this
  # call
  __babashka_log "== ${FUNCNAME[0]} $_package_name"
  get_id() {
    echo "${_package_name}"
  }
  is_met() {
    brew list "${_package_name}" > /dev/null 2>&1
  }
  meet() {
    [ -n "$__babushka_force" ] && brew_flags="${brew_flags} -f"
    brew install "$brew_flags" -q "${_package_name}"
  }
  process
}

system.package.absent.brew() {
  local _package_name=$1; shift
  
  # Any flags you want to set should be set via apt_flags= outside this
  # call
  __babashka_log "== ${FUNCNAME[0]} $_package_name"
  get_id() {
    echo "${_package_name}"
  }
  is_met() {
    brew list "${_package_name}" > /dev/null 2>&1
    $? && return 1
    return 0
  }
  meet() {
    [ -n "$__babushka_force" ] && brew_flags="${brew_flags} -f"
    brew uninstall "$brew_flags" -q "${_package_name}"
  }
  process
}

system.info.like "macos" || return 0

system.package() {
  system.package.brew "$@"
}

system.package.absent() {
  system.package.absent.brew "$@"
}