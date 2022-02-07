system_file_contents() {
  # system.file /tmp/test_file_contents -c "hello world"
  system.file /tmp/test_file_contents -c "hello, world" -o vagrant
}

system_file_source() {
  system.file /tmp/test_file_template \
    -s /vagrant/tests/files/test_source
}

system_file_absent() {
  requires system_file_contents
  system.file.absent /tmp/test_file_contents
}
