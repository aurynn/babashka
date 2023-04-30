system_user() {
  
  system.user testuser
}

system_user_groups() {
  
  system.user testuser
  system.user.groups testuser \
    -g adm \
    -g sudo
}