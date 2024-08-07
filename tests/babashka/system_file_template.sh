ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
system_file_template() {
  NAME="test_user" \
    system.file.template /tmp/template \
      -t ${ABSOLUTE_PATH}/../files/templates/test_one_variable.mo
}

system_file_template_variables_file() {
  ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  system.file.template /tmp/template \
    -t ${ABSOLUTE_PATH}/../files/templates/test_two_variables.mo \
    -s ${ABSOLUTE_PATH}/../files/templates/variables/two_variables.sh
}

system_file_template_two_variable_files() {
  ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  system.file.template /tmp/template \
    -t ${ABSOLUTE_PATH}/../files/templates/test_two_variables.mo \
    -s ${ABSOLUTE_PATH}/../files/templates/variables/variable_one.sh \
    -s ${ABSOLUTE_PATH}/../files/templates/variables/variable_two.sh
}

system_file_template_owner_root() {
  ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  system.file.template /tmp/template \
    -t ${ABSOLUTE_PATH}/../files/templates/test_two_variables.mo \
    -s ${ABSOLUTE_PATH}/../files/templates/variables/two_variables.sh \
    -o root
}


system_file_template_group_root() {
  ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  system.file.template /tmp/template \
    -t ${ABSOLUTE_PATH}/../files/templates/test_two_variables.mo \
    -s ${ABSOLUTE_PATH}/../files/templates/variables/two_variables.sh \
    -g root \
    -o root
}

system.file.template.foreach() {
  ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  system.file.template /tmp/template \
    -t ${ABSOLUTE_PATH}/../files/templates/test_foreach.mo \
    -s ${ABSOLUTE_PATH}/../files/templates/test_foreach_variables
}

system.file.template.has_changed() {
  ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  system.file.template /tmp/template_changed \
    -t ${ABSOLUTE_PATH}/../files/templates/test_foreach.mo \
    -s ${ABSOLUTE_PATH}/../files/templates/test_foreach_variables
  on_change "system.file.template:/tmp/template_changed" && __babashka_log "change noted"
}