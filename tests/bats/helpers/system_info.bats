DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
load "../../bats_helpers/bats-support/load"
load "../../bats_helpers/bats-assert/load"
# load "../../helpers/system_info.sh"

setup() {
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  
  # Load Babashka itself
  . "${DIR}/../../../bin/babashka"
  # load the bats helpers
  . "${DIR}/../../../helpers/01-core.sh"
  . "${DIR}/../../../helpers/system_info.sh"
}

# setup() {
#     # get the containing directory of this file
#     # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
#     # as those will point to the bats executable's location or the preprocessed file respectively
#     # make executables in src/ visible to PATH
# }

# @test "can source the babashka binary" {
#   . babashka
# }

@test "system info is populated" {
  assert [ "${#__babashka_system_info[@]}" -gt 0 ]
}

@test "system.info.test error on missing segment" {
  run system::info::test
  [ "$status" -eq 2 ]
}

@test "system.info.test error on missing testable" {
  run system::info::test ID_LIKE
  [ "$status" -eq 3 ]
}

@test "system::info::test error on invalid segment" {
  run system::info::test INVALID_SEGMENT "some value"
  [ "$status" -eq 4 ]
}

@test "system::info::test matches current ARCH" {
  current_uname="$(uname -m)"
  system::info::test ARCH $current_uname
}