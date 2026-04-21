DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
load "../../bats_helpers/bats-support/load"
load "../../bats_helpers/bats-assert/load"
# load "../../helpers/system_info.sh"

declare -Ag __KITBASH_VAR_FILE_CACHE

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
  # unset KITBASH_VARIABLE_PATHS
}

teardown() {
  unset KITBASH_VARIABLE_PATHS
  unset KITBASH_CURRENT_MODEL
  unset __KITBASH_VAR_FILE_CACHE
  
  unset KITBASH_MODEL_INHERITANCE
  unset __KITBASH_MODEL_TREE_STACK
}

##
## Test the kitbash.vars.files.lookup code paths specifically, to test the
## override functionality.
## Files now doesn't bother trying to parse files before looking in the cache;
## it now loads everything into a dict and goes from there automatically.
##

@test "kitbash.vars.files.lookup caches basic files" {
  # KITBASH_LOG_LEVEL=0
  KITBASH_VARIABLE_PATHS=("$DIR/variables/basic")
  kitbash.vars.files.init
  run kitbash.vars.files.lookup "GREETING"
  assert_output "hello"
}

@test "kitbash.vars.files.lookup uses reverse lexical sort for files" {
  KITBASH_VARIABLE_PATHS=("$DIR/variables/basic")
  kitbash.vars.files.init
  run kitbash.vars.files.lookup "DEPARTURE"
  assert_output "departed"
}

@test "kitbash.vars.files.lookup model script file overrides" {
  # KITBASH_LOG_LEVEL=0
  KITBASH_VARIABLE_PATHS=("$DIR/variables/basic" "$DIR/variables/with_model_script")
  __KITBASH_MODEL_TREE_STACK=(modelname)
  KITBASH_CURRENT_MODEL=modelname
  kitbash.vars.files.init
  run kitbash.vars.files.lookup "GREETING"
  assert_output "modelname"
}

@test "kitbash.vars.files.lookup model directory overrides" {
  # KITBASH_LOG_LEVEL=0
  
  __KITBASH_MODEL_TREE_STACK=(modelname)
  KITBASH_VARIABLE_PATHS=("$DIR/variables/basic" "$DIR/variables/with_model_dir")
  KITBASH_CURRENT_MODEL=modelname
  kitbash.vars.files.init
  run kitbash.vars.files.lookup "GREETING"
  assert_output "modelname_directory"
}

@test "kitbash.vars.files.lookup returns warn for trailing 'n'" {
  KITBASH_VARIABLE_PATHS=("$DIR/variables/basic")
  # KITBASH_LOG_LEVEL=0
  kitbash.vars.files.init
  run kitbash.vars.files.lookup "TRAILING_N"
  assert_output warn
}

#
# Test the info.var path specifically
#


@test "info.var returns present value" {
  # KITBASH_LOG_LEVEL=0
  KITBASH_VARIABLE_PATHS=("$DIR/variables/basic")
  kitbash.vars.files.init
  run info.var "GREETING"
  assert_output "hello"
}

@test "info.var fails on missing" {
  KITBASH_VARIABLE_PATHS=("$DIR/variables/basic")
  kitbash.vars.files.init
  run info.var "MISSING"
  assert_failure 1
}

@test "info.var model script file overrides" {
  # KITBASH_LOG_LEVEL=0
  KITBASH_VARIABLE_PATHS=("$DIR/variables/basic" "$DIR/variables/with_model_script")
  __KITBASH_MODEL_TREE_STACK=(modelname)
  KITBASH_CURRENT_MODEL=modelname
  kitbash.vars.files.init
  run info.var "GREETING"
  assert_output "modelname"
}

@test "info.var returns quoted value" {
  KITBASH_VARIABLE_PATHS=("$DIR/variables/quoted")
  kitbash.vars.files.init
  run info.var "GREETING"
  assert_output "asd"
}

@test "info.var returns warn for trailing 'n'" {
  KITBASH_VARIABLE_PATHS=("$DIR/variables/basic")
  kitbash.vars.files.init
  run info.var "TRAILING_N"
  assert_output warn
}

