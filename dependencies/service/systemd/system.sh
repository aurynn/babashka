# Manage systemd units

system.service.enable.systemd() {
  local _unit="$1"
  shift
  
  # check if the unit even exists; if it doesn't this makes no sense
  if systemctl is-enabled "$_unit" 2>&1 | grep -q "No such file or directory" ; then
    __babashka_fail "Unit $_unit not installed"
  fi
  
  function get_id() {
    echo "${_unit}"
  }

  is_met() {
    # how do we check if a systemd service is enabled?
    systemctl is-enabled "$_unit" 2>/dev/null | grep -q "enabled"
  }
  meet() {
    systemctl enable "$_unit" 2>&1 > /dev/null;
  }
  process
}

system.service.disable.systemd() {
  local _unit="$1"
  shift
  
  # check if the unit even exists; if it doesn't this makes no sense
  if systemctl is-enabled "$_unit" 2>&1 | grep -q "No such file or directory" ; then
    kitbash.fail "No such unit $_unit"
  fi
  
  get_id() {
    printf '%s\n' "${_unit}"
  }

  is_met() {
    # how do we check if a systemd service is enabled?
    systemctl is-enabled "$_unit" 2>/dev/null | grep -q "disabled"
  }
  meet() {
    systemctl disable "$_unit" > /dev/null 2>&1
  }
  process
}

system.service.start.systemd() {
  local _unit
  _unit="$1"
  shift
  get_id() {
    printf "%s\n" "$_unit"
  }
  is_met() {
    systemctl is-active "$_unit" 2>/dev/null | grep -q "^active$"
  }
  meet() {
    systemctl start "$_unit" > /dev/null 2>&1
  }
  process
}

system.service.stop.systemd() {
  local unit
  unit="$1"
  shift
  get_id() {
    printf "%s\n" "$unit"
  }
  is_met() {
    systemctl is-active "$unit" | grep -q "^inactive$"
  }
  meet() {
    systemctl stop "$unit" > /dev/null 2>&1
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
    emit info "Checking if $_unit is enabled..."
    systemctl is-active "$_unit" | grep -q "^active$" || {
      kitbash.fail "Unit $_unit not active"
    }
    emit info "$_unit is enabled"
    return "$has_met"
  }
  meet() {
    emit info "reloading $_unit"
    systemctl reload "$_unit" > /dev/null 2>&1
    st="$?"
    if (( "$st" != 0 )); then
      emit error "Could not restart"
    fi
    has_met="$st"
    return "$st"
  }
  process
}


system.service.restart.systemd() {
  local _unit=$1; shift
  emit info "$_unit"
  
  # check if the unit even exists; if it doesn't this makes no sense
  if ! systemctl list-unit-files "$_unit.service" 2>&1 > /dev/null; then
    kitbash.fail "No such unit $_unit"
  fi
  
  get_id() {
    echo "${_unit}"
  }
  
  local not_started status has_been_restarted
  not_started=1
  has_been_restarted=1
  is_met() {
    # how do we check if a systemd service is enabled?
    [[ "$has_been_restarted" == 0 ]] && return 0
    emit info "Checking if $_unit is enabled..."
    
    systemctl is-active "$_unit" | grep -q "^active$" || {
      emit error "Unit $_unit not active! Marking for start..."
      not_started=0
      return 1
      # kitbash.fail "Unit $_unit not active"
    }
    emit info "$_unit is active"
    return "$not_started"
  }
  meet() {
    if [[ "$not_started" == 0 ]]; then
      # To do: capture logging output from this properly
      emit info "Starting $_unit..."
      systemctl start "$_unit" > /dev/null 2>&1
      status="$?"
    else
      emit info "Restarting $_unit..."
      systemctl restart "$_unit" > /dev/null 2>&1
      status="$?"
    fi
    [[ "$status" == 0 ]] && {
      has_been_restarted=0
    }
    return "$status"
  }
  process
}
system.service.reload-or-restart.systemd() {
  local _unit="$1";
  shift
  
  # check if the unit even exists; if it doesn't this makes no sense
  if ! systemctl list-unit-files "$_unit.service" > /dev/null 2>&1; then
    kitbash.fail "No such unit $_unit"
  fi
  
  get_id() {
    printf '%s\n' "${_unit}"
  }
  
  local has_met
  has_met=1
  is_met() {
    # how do we check if a systemd service is enabled?
    emit info "Checking if $_unit is active"
    systemctl is-active "$_unit" 2> /dev/null | grep -q "^active$" || {
      kitbash.fail "Unit $_unit not active"
    }
    emit info "... active"
    return $has_met
  }
  meet() {
    local status
    emit info "reloading-or-restarting $_unit"
    systemctl reload-or-restart "$_unit" > /dev/null 2>&1
    status="$?"
    if [[ "$status" ]]; then
      emit ok "... success"
      has_met=0
    fi
    return "$status"
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