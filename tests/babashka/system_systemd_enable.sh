# system_systemd_enable() {
# 
#   system.service.enable acpid.service
# }
# 
# system_systemd_enable_missing() {
# 
#   system.service.enable nonexistent.service
# }

system_enable() {
  system.package nginx
  system.service.enable nginx
}

system_disable() {
  system.service.disable nginx
}

system_start_service() {
  system.service.started nginx
}
system_stop_service() {
  system.service.stopped nginx
}