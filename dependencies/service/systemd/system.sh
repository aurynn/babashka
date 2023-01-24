# Manage systemd units

system.service.enable() {
  local _unit=$1; shift

  __babashka_log "${FUNCNAME[0]} $_unit"
  # check if the unit even exists; if it doesn't this makes no sense
  if systemctl is-enabled "$_unit" | grep -q "No such file or directory" > /dev/null ; then
    __babashka_fail "${FUNCNAME[0]}: Unit $_unit not installed"
  fi

  is_met() {
    # how do we check if a systemd service is enabled?
    systemctl is-enabled "$_unit" | grep -q "enabled"
  }
  meet() {
    $__babashka_sudo systemctl enable "$_unit" 2>&1 > /dev/null;
  }
  process
}

system.service.disable() {
  local _unit=$1; shift
  __babashka_log "${FUNCNAME[0]} $_unit"

  # check if the unit even exists; if it doesn't this makes no sense
  if systemctl is-enabled "$_unit" | grep -q "No such file or directory" > /dev/null ; then
    __babashka_fail "${FUNCNAME[0]}: Unit $_unit not installed"
  fi

  is_met() {
    # how do we check if a systemd service is enabled?
    systemctl is-enabled "$_unit" | grep -q "disabled"
  }
  meet() {
    $__babashka_sudo systemctl disable $_unit 2>&1 > /dev/null;
  }
  process
}
