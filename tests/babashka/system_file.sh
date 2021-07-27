system_file_contents() {
  # system.file /tmp/test_file_contents -c "hello world"
  system.file /tmp/test_file_contents -c "hello, world" -u vagrant
}

system_file_source() {
  system.file /tmp/test_file_template -s /vagrant/tests/files/test_source
}
