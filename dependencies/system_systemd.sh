# Manage systemd units

system.systemd.enable() {
  local _unit=$1; shift

  __babashka_log "${FUNCNAME[0]} $_unit"
  # check if the unit even exists; if it doesn't this makes no sense
  if ! systemctl list-unit-files | grep "$_unit" > /dev/null ; then
    __babashka_fail "unit $_unit not installed"
  fi

  is_met() {
    # how do we check if a systemd service is enabled?
    systemctl list-unit-files | grep "$_unit" | grep enabled
  }
  meet() {
    $__babashka_sudo systemctl enable $_unit
  }
  process
}
