function system.package() {
  local _package_name=$1; shift
  
  # Any flags you want to set should be set via apt_flags= outside this
  # function call
  __babashka_log "== ${FUNCNAME[0]} (apt) $_package_name"
  function get_id() {
    echo "${_package_name}"
  }
   function is_met() {
     dpkg -s ${apt_pkg:-$_package_name} 2>&1 > /dev/null
   }
   function meet() {
     [ -n "$__babushka_force" ] && apt_flags="${apt_flags} -f --force-yes"
     DEBIAN_FRONTEND=noninteractive $__babashka_sudo apt-get -yqq install $apt_flags ${apt_pkg:-$_package_name}
   }
  process
}

function system.package.absent() {
  local _package_name=$1; shift;

  __babashka_log "== ${FUNCNAME[0]} (apt) $_package_name"
  function get_id() {
    echo "${_package_name}"
  }
  function is_met() {
    dpkg -s ${apt_pkg:-$_package_name} 2>&1 > /dev/null && return 1
     return 0
   }
   function meet() {
    [ -n "$__babushka_force" ] && apt_flags="${apt_flags} -f --force-yes"
    DEBIAN_FRONTEND=noninteractive $__babashka_sudo apt-get -yqq remove $apt_flags ${apt_pkg:-$_package_name}
    DEBIAN_FRONTEND=noninteractive $__babashka_sudo apt-get -yqq autoremove
   }
  process
}

# function system.packages() {
#   
#   local all_pkgs=""
#   for param in "$@"; do
#       # Concatenate each parameter to the string variable, separated by a space
#       all_pkgs+=" $param"
#   done
#   # Trim leading whitespace
#   all_pkgs="${all_pkgs:1}"
#   __babashka_log "${FUNCNAME[0]} (apt) $all_pkgs"
#   
#   local _copy_of_input=("$@");
#   local _missing_packages=()
#   function is_met() {
#     for pkg in "${_copy_of_input[@]}"; do
#       if ! dpkg -s ${apt_pkg:-$pkg} 2>&1 > /dev/null; then
#         _missing_packages+=("$pkg")
#       fi
#     done
#     [ ${#_missing_packages[@]} -eq 0 ]
#   }
#   function meet() {
#     [ -n "$__babushka_force" ] && apt_flags="${apt_flags} -f --force-yes"
#     printf "%s\n" "${_missing_packages[@]}" | DEBIAN_FRONTEND=noninteractive $__babashka_sudo xargs -d '\n' apt-get -y install
#   }
#   process
# }