function system.package.pip() {
  local _package_name=$1; shift

  while getopts "us:" opt; do
    case "$opt" in
    s)
      local _source=$OPTARG;;
    u)
      # Enable the upgrade flag
      local _upgrade_flag="-U";;
    esac
  done

  unset OPTIND
  unset OPTARG

  __funcname=${FUNCNAME[0]}
  __babashka_log "${FUNCNAME[0]} $_package_name"
  function is_met() {
    /usr/bin/pip3 -qqq show $_package_name
  }
  function meet() {
    if [ "$_source " != " " ] ; then
      $__babashka_sudo /usr/bin/pip3 -qqq install "$_source" && return $?
    else
      # Assumes that we're trying to install from PyPI
      $__babashka_sudo /usr/bin/pip3 -qqq install "$_package_name" && return $?
    fi
  }
  process
}

function system.package.pip.absent() {
  # Remove a Pip package
  local _package_name=$1; shift

  __funcname=${FUNCNAME[0]}
  __babashka_log "${FUNCNAME[0]} $_package_name"
  function is_met() {
    /usr/bin/pip3 -qqq show $_package_name && return 1
    return 0
  }
  function meet() {
    $__babashka_sudo /usr/bin/pip3 -qqq uninstall -y "$_package_name"
  }
  process
}
