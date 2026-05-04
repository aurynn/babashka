# Manage systemd units

system.service.enable.systemd() {
  local _unit=$1; shift

  __babashka_log "== ${FUNCNAME[0]} (systemd) $_unit"
  # check if the unit even exists; if it doesn't this makes no sense
  if systemctl is-enabled "$_unit" 2>&1 | grep -q "No such file or directory" ; then
    __babashka_fail "${FUNCNAME[0]} (systemd): Unit $_unit not installed"
  fi
  
  function get_id() {
    echo "${_unit}"
  }

  is_met() {
    # how do we check if a systemd service is enabled?
    systemctl is-enabled "$_unit" | grep -q "enabled"
  }
  meet() {
    $__babashka_sudo systemctl enable "$_unit" 2>&1 > /dev/null;
  }
  process
}

system.service.disable.systemd() {
  local _unit=$1; shift
  __babashka_log "== ${FUNCNAME[0]} (systemd)  $_unit"

  # check if the unit even exists; if it doesn't this makes no sense
  if systemctl is-enabled "$_unit" 2>&1 | grep -q "No such file or directory" ; then
    kitbash.fail "No such unit $_unit"
  fi
  
  get_id() {
    echo "${_unit}"
  }

  is_met() {
    # how do we check if a systemd service is enabled?
    systemctl is-enabled "$_unit" | grep -q "disabled"
  }
  meet() {
    systemctl disable "$_unit" > /dev/null 2>&1
  }
  process
}

system.service.start.systemd() {
  local _unit
  unit="$1"
  shift
  emit "$_unit"
  get_id() {
    printf "%s\n" "$_unit"
  }
  is_met() {
    systemctl is-active "$_unit" | grep -q "active"
  }
  meet() {
    systemctl start "$_unit" > /dev/null 2>&1
  }
  process
}
system.service.stop.systemd() {
  local _unit
  unit="$1"
  shift
  emit "$_unit"
  get_id() {
    printf "%s\n" "$_unit"
  }
  is_met() {
    systemctl is-active "$_unit" | grep -q "inactive"
  }
  meet() {
    systemctl start "$_unit" > /dev/null 2>&1
  }
  process
}

system.service.reload.systemd() {
  local _unit=$1; shift
  emit info "$_unit"
  
  # check if the unit even exists; if it doesn't this makes no sense
  if systemctl is-enabled "$_unit" 2>&1 | grep -q "No such file or directory" ; then
    kitbash.fail "No such unit $_unit"
  fi
  
  get_id() {
    echo "${_unit}"
  }
  
  local has_met
  has_met=1
  is_met() {
    # how do we check if a systemd service is enabled?
    emit info "Checking enabled"
    systemctl is-active "$_unit" | grep -q "active" || {
      kitbash.fail "Unit $_unit not active"
    }
    return "$has_met"
  }
  meet() {
    systemctl reload "$_unit" > /dev/null 2>&1
    has_met=0
  }
  process
}
system.service.restart.systemd() {
  local _unit=$1; shift
  emit info "$_unit"
  
  # check if the unit even exists; if it doesn't this makes no sense
  if ! systemctl list-unit-files "$_unit.service" 2>&1; then
    kitbash.fail "No such unit $_unit"
  fi
  
  get_id() {
    echo "${_unit}"
  }
  
  local has_met
  has_met=1
  is_met() {
    # how do we check if a systemd service is enabled?
    emit info "Checking enabled"
    systemctl is-active "$_unit" | grep -q "active" || {
      kitbash.fail "Unit $_unit not active"
    }
    return "$has_met"
  }
  meet() {
    emit info "restarting process"
    systemctl restart "$_unit" > /dev/null 2>&1
    if [[ $? ]]; then
      has_met=0
    fi
    return $?
  }
  process
}
system.service.reload-or-restart.systemd() {
  local _unit=$1; shift
  emit info "$_unit"
  
  # check if the unit even exists; if it doesn't this makes no sense
  if ! systemctl list-unit-files "$_unit.service" 2>&1; then
    kitbash.fail "No such unit $_unit"
  fi
  
  get_id() {
    echo "${_unit}"
  }
  
  local has_met
  has_met=1
  is_met() {
    # how do we check if a systemd service is enabled?
    emit info "Checking enabled"
    systemctl is-active "$_unit" | grep -q "active" || {
      kitbash.fail "Unit $_unit not active"
    }
    return "$has_met"
  }
  meet() {
    emit info "restarting process"
    systemctl reload-or-restart "$_unit" > /dev/null 2>&1
    if [[ $? ]]; then
      has_met=0
    fi
    return $?
  }
  process
}

system.info.init systemd || return

system.service.enable() {
  system.service.enable.systemd "$@"
}
system.service.disable() {
  system.service.disable.systemd "$@"
}
system.service.start() {
  system.service.start.systemd "$@"
}
system.service.stop() {
  system.service.stop.systemd "$@"
}
system.service.reload() {
  system.service.reload.systemd "$@"
}
system.service.restart() {
  system.service.restart.systemd "$@"
}
system.service.reload-or-restart() {
  system.service.reload-or-restart.systemd "$@"
}