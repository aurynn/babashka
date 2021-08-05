system_systemd_enable() {

  system.systemd.enable acpid.service
}

system_systemd_enable_missing() {

  system.systemd.enable nonexistent.service
}
