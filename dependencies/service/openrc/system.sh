system.service.enable() {
  local _unit=$1; shift
  
  __babashka_log "== ${FUNCNAME[0]} (openrc) $_unit"
  
  while getopts "l:" opt; do
    case "$opt" in
      # echoing through xargs trims whitespace
      l)
        _runlevel=$(echo $OPTARG | xargs);;
    esac
  done
  # Reset the option parsing
  unset OPTIND
  unset OPTARG
  
  if ! [ -e /etc/init.d/$_unit ]; then
    __babashka_fail "${FUNCNAME[0]} (openrc) No service $_unit."
  fi
  
  if [[ "$_runlevel " == " " ]]; then
    _runlevel="default"
  fi
  
  function get_id() {
    echo "${_unit}"
  }
  function is_met() {
    rc-update show | grep "$_unit" | grep -q "$_runlevel"
  }
  function meet() {
    $__babashka_sudo rc-update add $_unit $_runlevel
  }
  process
}

system.service.disable() {
  local _service=$1; shift
  
  __babashka_log "== ${FUNCNAME[0]} (openrc) $_service"
  
  while getopts "l:" opt; do
    case "$opt" in
      # echoing through xargs trims whitespace
      l)
        _runlevel=$(echo $OPTARG | xargs);;
    esac
  done
  # Reset the option parsing
  unset OPTIND
  unset OPTARG
  
  if ! [ -e /etc/init.d/$_service ]; then
    __babashka_fail "${FUNCNAME[0]} (openrc) No service $_unit."
  fi
  
  if [[ "$_runlevel " == " " ]]; then
    _runlevel="default"
  fi
  
  function get_id() {
    echo "${_service}"
  }
  
  function is_met() {
    ! rc-update show | grep $_service | grep -q $_runlevel
  }
  function meet() {
    $__babashka_sudo rc-update delete $_service
  }
  process
}

system.service.started() {
  local _service=$1; shift
  __babashka_log "== ${FUNCNAME[0]} (openrc) $_service"
  
  if ! [ -e /etc/init.d/$_service ]; then
    __babashka_fail "${FUNCNAME[0]} (openrc) No service $_unit."
  fi
  
  function get_id() {
    echo "${_service}"
  }
  function is_met() {
    rc-service $_service status | grep -q "status: started"
  }
  function meet() {
    $__babashka_sudo rc-service $_service start > /dev/null
  }
  process
}

system.service.stopped() {
  local _service=$1; shift
  __babashka_log "== ${FUNCNAME[0]} (openrc) $_service"
  
  if ! [ -e /etc/init.d/$_service ]; then
    __babashka_fail "${FUNCNAME[0]} (openrc) No service $_unit."
  fi
  
  function get_id() {
    echo "${_service}"
  }
  
  function is_met() {
    rc-service $_service status | grep -q "status: stopped"
  }
  function meet() {
    $__babashka_sudo rc-service $_service stop > /dev/null
  }
  process
}