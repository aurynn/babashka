function system.package.pip() {
  local _package_name=$1; shift

  __funcname=${FUNCNAME[0]}
  __babashka_log "${FUNCNAME[0]} $_package_name"
  function is_met() {
    /usr/bin/pip -qqq show $_package_name
  }
  function meet() {
    $__babashka_sudo /usr/bin/pip -qqq install "$_package_name"
  }
  process
}

function system.package.pip.absent() {
  # Remove a Pip package
  local _package_name=$1; shift

  __funcname=${FUNCNAME[0]}
  __babashka_log "${FUNCNAME[0]} $_package_name"
  function is_met() {
    /usr/bin/pip -qqq show $_package_name && return 1
    return 0
  }
  function meet() {
    $__babashka_sudo /usr/bin/pip -qqq uninstall -y "$_package_name"
  }
  process
}
