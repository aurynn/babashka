system.package.pacman() {
  local _package_name=$1; shift
  ## TODO
  ## Add flags handling?
  __babashka_log "== ${FUNCNAME[0]} $_package_name"
  get_id() {
    echo "${_package_name}"
  }
   is_met() {
     $__babashka_sudo pacman -Q ${_package_name} 2>&1 > /dev/null
   }
   meet() {
     $__babashka_sudo pacman -Sq --noconfirm --noprogressbar ${pacman_flags} ${_package_name} 2>&1 > /dev/null
   }
  process
}

system.package.absent.pacman() {
  local _package_name=$1; shift;

  __babashka_log "== ${FUNCNAME[0]} $_package_name"
  get_id() {
    echo "${_package_name}"
  }
  is_met() {
    $__babashka_sudo pacman -Q ${_package_name} 2>&1 > /dev/null && return 1
    return 0
   }
   meet() {
    # [ -n "$__babushka_force" ] && pacman_flags="${pacman_flags} -f --force-yes"
    $__babashka_sudo pacman -Runs --noconfirm --noprogressbar ${_package_name} 2>&1 > /dev/null
   }
  process
}

# Don't define the main system.package functions unless we need to.

system.info.like "arch" || return 0

system.package() {
  system.package.pacman "$@"
}

system.package.absent() {
  system.package.absent.pacman "$@"
}