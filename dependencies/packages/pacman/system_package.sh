function system.package() {
  local _package_name=$1; shift
  # Any flags you want to set should be set via apt_flags= outside this
  # function call
  __babashka_log "== ${FUNCNAME[0]} (pacman) $_package_name"
  function get_id() {
    echo "${_package_name}"
  }
   function is_met() {
     pacman -Q ${_package_name} 2>&1 > /dev/null
   }
   function meet() {
     $__babashka_sudo pacman -Sq --noconfirm --noprogressbar ${pacman_flags} ${_package_name} 2>&1 > /dev/null
   }
  process
}

function system.package.absent() {
  local _package_name=$1; shift;

  __babashka_log "== ${FUNCNAME[0]} (pacman) $_package_name"
  function get_id() {
    echo "${_package_name}"
  }
  function is_met() {
    pacman -Q ${_package_name} 2>&1 > /dev/null && return 1
    return 0
   }
   function meet() {
    # [ -n "$__babushka_force" ] && pacman_flags="${pacman_flags} -f --force-yes"
    $__babashka_sudo pacman -Runs --noconfirm --noprogressbar ${_package_name} 2>&1 > /dev/null
   }
  process
}
