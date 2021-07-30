system_file_template() {
  NAME="test_user" \
    system.file.template /tmp/template -t /vagrant/tests/files/templates/test_one_variable.mo
}

system_file_template_variables_file() {
  system.file.template /tmp/template \
    -t /vagrant/tests/files/templates/test_two_variables.mo \
    -s /vagrant/tests/files/templates/variables/two_variables.sh
}

system_file_template_owner_root() {
  system.file.template /tmp/template \
    -t /vagrant/tests/files/templates/test_two_variables.mo \
    -s /vagrant/tests/files/templates/variables/two_variables.sh \
    -o root
}


system_file_template_group_root() {
  system.file.template /tmp/template \
    -t /vagrant/tests/files/templates/test_two_variables.mo \
    -s /vagrant/tests/files/templates/variables/two_variables.sh \
    -g root \
    -o root
}
