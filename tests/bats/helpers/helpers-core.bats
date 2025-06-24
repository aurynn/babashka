load "../../bats_helpers/bats-support/load"
load "../../bats_helpers/bats-assert/load"

setup_file() {
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  load "${DIR}/../../../bin/babashka"
  # load the babashka core functions
  . "${DIR}/../../../helpers/01-core.sh"
}

setup() {
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  . "${DIR}/../../../helpers/01-core.sh"
}

@test "element_in_array detects element" {
  test_array=(one two three four)
  assert bb::core::element_in_array one "${test_array[@]}"
}

@test "element_in_array rejects missing element" {
  test_array=(one two three four)
  refute bb::core::element_in_array five "${test_array[@]}"
}

@test "normalise_string collapses leading whitespace" {
  test_string="    TEST"
  assert [ "$(bb::core::normalise_string "$test_string")" = "TEST" ]
}

@test "normalise_string collapses trailing whitespace" {
  test_string="TEST    "
  assert [ "$(bb::core::normalise_string "$test_string")" = "TEST" ]
}

@test "normalise_string collapses internal whitespace" {
  test_string="TEST   STRING"
  assert [ "$(bb::core::normalise_string "$test_string")" = "TEST STRING" ]
}

@test "casefold ascii string" {
  test_string="TEST STRING"
  assert [ "$(bb::core::casefold "$test_string")" = "test string" ]
}

@test "casefold utf-8 string" {
  test_string="TÉST STRÎNG"
  assert [ "$(bb::core::casefold "$test_string")" = "tést strîng" ]
}