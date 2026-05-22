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
  system.service.start nginx
}

system_stop_service() {
  system.service.stop nginx
}

system_restart_service() {
  system.service.restart nginx
}
system_reload_service() {
  system.service.reload nginx
}

system_reload_or_restart_service() {
  system.service.reload-or-restart nginx
}