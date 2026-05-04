DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
load "../../bats_helpers/bats-support/load"
load "../../bats_helpers/bats-assert/load"
# load "../../helpers/system_info.sh"

declare -Ag __KITBASH_SECRET_FILE_CACHE

setup() {
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  
  # Load Babashka itself
  . "${DIR}/../../../bin/babashka"
  # load the bats helpers
  . "${DIR}/../../../helpers/00-color.sh"
  . "${DIR}/../../../helpers/00-log.sh"
  . "${DIR}/../../../helpers/01-core.sh"
  . "${DIR}/../../../helpers/02-system_info.sh"
  . "${DIR}/../../../helpers/variables.sh"
  export KITBASH_TEST_CALLER="$BATS_TEST_FILENAME"
  unset KITBASH_SECRETS_PATHS
  # __KITBASH_MODEL_TREE_STACK=(modelname)
  # KITBASH_LOG_LEVEL=0
  # # Should? overwrite the values.
  # declare -Ag __KITBASH_VAR_FILE_CACHE
  # declare -Ag __KITBASH_SECRET_FILE_CACHE
}

teardown() {
  unset KITBASH_SECRETS_PATHS
  unset KITBASH_CURRENT_MODEL
  unset KITBASH_MODEL_INHERITANCE
  unset __KITBASH_MODEL_TREE_STACK
}

@test "info.var.secret returns present secret" {
  
  # Need to re-run init as we're 
  KITBASH_SECRETS_PATHS=("$DIR/variables/basic")
  kitbash.secrets.files.init
  run info.var.secret "GREETING"
  assert_output "hello"
}

@test "info.var.secret fails on missing" {
  KITBASH_SECRETS_PATHS=("$DIR/variables/basic")
  kitbash.secrets.files.init
  run info.var.secret "MISSING"
  assert_failure 1
}

# bats test_tags=override
@test "info.var.secret model script file overrides" {
  # KITBASH_LOG_LEVEL=0
  KITBASH_SECRETS_PATHS=("$DIR/variables/basic" "$DIR/variables/with_model_script")
  KITBASH_MODEL_INHERITANCE=(modelname)
  __KITBASH_MODEL_TREE_STACK=(modelname)
  KITBASH_CURRENT_MODEL=modelname
  # Re-run secrets init, since it runs over the secrets paths at startup
  kitbash.secrets.files.init
  
  run info.var.secret "GREETING"
  assert_output "modelname"
}