function system.package() {
  local _package_name=$1; shift
  local _platform=`uname -s`
  # -a == apt
  # -b == brew
  while getopts "a:b:" opt; do
    case "$opt" in
      a)
        local apt_pkg=$OPTARG;;
      b)
        local brew_pkg=$OPTARG;;
    esac
  done
  unset OPTIND
  unset OPTARG
  # Any flags you want to set should be set via apt_flags= outside this
  # function call
  __babashka_log "${FUNCNAME[0]} $_package_name"
  case "`uname -s`" in
    Linux)
     # TODO: things other than Debian derivatives
     function is_met() {
       dpkg -s ${apt_pkg:-$_package_name} 2>&1 > /dev/null
     }
     function meet() {
       [ -n "$__babushka_force" ] && apt_flags="${apt_flags} -f --force-yes"
       DEBIAN_FRONTEND=noninteractive $__babashka_sudo apt-get -yqq install $apt_flags ${apt_pkg:-$_package_name}
     }
     ;;
   Darwin)
     # TODO things other than brew
     function is_met() {
       brew list | grep ${brew_pkg:-$_package_name}
     }
     function meet() {
       brew install ${brew_pkg:-$_package_name}
     }
     ;;
  esac
  process
}

function system.package.absent() {
  local _package_name=$1; shift;

  __babashka_log "${FUNCNAME[0]} $_package_name"
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
