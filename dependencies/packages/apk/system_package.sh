system.package.apk() {
  local _package_name="$1"
  # TODO:
  #   should this allow some kind of flags input situation?
  __babashka_log "== ${FUNCNAME[0]} $_package_name"
  get_id() {
    echo "${_package_name}"
  }
   is_met() {
     apk -e info "${_package_name}" 2>&1 > /dev/null
   }
   meet() {
     apk "${apk_flags}" add "${_package_name}" 2>&1 > /dev/null
   }
  process
}

system.package.absent.apk() {
  local _package_name="$1";
  
  __babashka_log "== ${FUNCNAME[0]} $_package_name"
  get_id() {
    echo "${_package_name}"
  }
  is_met() {
    apk -e info "${_package_name}" 2>&1 > /dev/null && return 1
    return 0
   }
   meet() {
    # [ -n "$__babushka_force" ] && pacman_flags="${pacman_flags} -f --force-yes"
    apk "${apk_flags}" del "${_package_name}" 2>&1 > /dev/null
   }
  process
}

# If we're not alpine, we don't want to define these as the default package
#   handlers.
# But, it's not unreasonable to want to run multiple package managers on the
#   same system, so, we can define the above safely.

system.info.like == "alpine" || return 0

system.package() {
  system.package.apk "$@"
}

system.package.absent() {
  system.package.absent.apk "$@"
}