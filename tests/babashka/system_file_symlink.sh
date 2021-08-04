system_file_symlink_succeed() {
  system.file.symlink /etc/profile /root/profile
}

system_file_symlink_fail_not_absolute() {
  system.file.symlink /etc/profile profile
}

system_file_symlink_source_does_not_exist() {
  system.file.symlink /path/to/nothing /root/dest
}
