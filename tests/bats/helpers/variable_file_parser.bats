DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
load "../../bats_helpers/bats-support/load"
load "../../bats_helpers/bats-assert/load"
# load "../../helpers/system_info.sh"

setup() {
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  
  # Load Babashka itself
  . "${DIR}/../../../bin/babashka"
  # load the Kitbash libraries we're testing.
  . "${DIR}/../../../helpers/00-color.sh"
  . "${DIR}/../../../helpers/00-log.sh"
  . "${DIR}/../../../helpers/01-core.sh"
  . "${DIR}/../../../helpers/02-system_info.sh"
  . "${DIR}/../../../helpers/variables.sh"
  export KITBASH_TEST_CALLER="$BATS_TEST_FILENAME"
  # Set log level to debug
  KITBASH_LOG_LEVEL=0
  # declare -g KITBASH_KV_PARSE_KEY
  # declare -g KITBASH_KV_PARSE_VAL
}

teardown() {
  # Clear the results we got back
  unset KITBASH_KV_PARSE_KEY
  unset KITBASH_KV_PARSE_VAL
}

@test "__kitbash_parse_line skips comment lines" {
  __kitbash_parse_line "# foo=\"bar\""
  # assert_success
  refute [ -n "$KITBASH_KV_PARSE_KEY" ]
  refute [ -n "$KITBASH_KV_PARSE_VAL" ]
}

@test "__kitbash_parse_line fails on non-kv lines" {
  run __kitbash_parse_line "foobar"
  assert_failure
}

@test "__kitbash_parse_line captures unquoted lines" {
  __kitbash_parse_line "foo=bar"
  
  assert_equal "$KITBASH_KV_PARSE_KEY" "foo"
  assert_equal "$KITBASH_KV_PARSE_VAL" "bar"
}

@test "__kitbash_parse_line works on lines with extended characters" {
  __kitbash_parse_line "foo=asdf#%^*@."
  
  assert_equal "$KITBASH_KV_PARSE_KEY" "foo"
  assert_equal "$KITBASH_KV_PARSE_VAL" "asdf#%^*@."
}

@test "__kitbash_parse_line unquoted lines allow #" {
  __kitbash_parse_line "foo=bar#baz"
  
  assert_equal "$KITBASH_KV_PARSE_KEY" "foo"
  assert_equal "$KITBASH_KV_PARSE_VAL" "bar#baz"
}

@test "__kitbash_parse_line captures quoted values" {
  __kitbash_parse_line 'foo="bar"'
  # assert_success
  assert_equal "$KITBASH_KV_PARSE_KEY" "foo"
  assert_equal "$KITBASH_KV_PARSE_VAL" "bar"
  
  __kitbash_parse_line "baz='foobaz'"
  assert_equal "$KITBASH_KV_PARSE_KEY" "baz"
  assert_equal "$KITBASH_KV_PARSE_VAL" "foobaz"
}

@test "__kitbash_parse_line allows internal escaped doublequotes" {
  __kitbash_parse_line 'foo="bar \"baz\""'
  # assert_success
  assert_equal "$KITBASH_KV_PARSE_KEY" "foo"
  assert_equal "$KITBASH_KV_PARSE_VAL" 'bar "baz"'
}

@test "__kitbash_parse_line allows internal escaped single quotes" {

  __kitbash_parse_line "baz='foo \'baz\''"
  assert_equal "$KITBASH_KV_PARSE_KEY" "baz"
  assert_equal "$KITBASH_KV_PARSE_VAL" "foo 'baz'"
}


@test "__parse_line parses LOG_LEVEL=warn" {
  __kitbash_parse_line "LOG_LEVEL=warn"
  assert_equal "$KITBASH_KV_PARSE_KEY" "LOG_LEVEL"
  assert_equal "$KITBASH_KV_PARSE_VAL" "warn"
}

@test "__parse_line aborts on unbalanced quote" {
  run __kitbash_parse_line "foo='bar"
  assert_failure
}