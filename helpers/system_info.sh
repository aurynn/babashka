# Provides some pleasant helper functions to make fetching certain system
#   information easier when writing configuration.

system.info() {
  system::info "$@"
}

system::info() {
  local segment
  segment="$(bb::core::normalise_string "$1")"
  # Generate the list of keys
  # local known_segments=("${!__babashka_system_info[@]}")
  
  # We have to define a segment to inspect
  [[ -n "$segment" ]] || return 2
  # If the segment isn't one we know to look for, abort
  # Skip the 2154 check, since __babashka_system_info is defined in
  #   bin/babashka, and this file is expected to be sourced by that.
  # TODO: Add some sort of exception if it's undefined?
  # shellcheck disable=SC2154
  bb::core::element_in_array "$1" "${!__babashka_system_info[@]}" || return 4
  
  # Fetch and normalise what we have in our array
  local value
  value="$(bb::core::normalise_string "${__babashka_system_info["$segment"]}")"
  
  echo "$value"
  return 0
}

##

system::info::test() {
  local segment
  local to_test
  segment="$(bb::core::normalise_string "$1")"
  to_test="$(bb::core::normalise_string "$2")"
  [[ -n "$segment" ]] || return 2
  [[ -n "$to_test" ]] || return 3
  local value
  local status
  value="$(system.info "$segment")"
  status=$?
  $status || return $status
  [[ "$value" == "$to_test" ]]
}

system.info.test() {
  system::info::test "$@"
}

##

system.info.like() { 
  system::info::like "$@"
}
system::info::like() { 
  system::info::test ID_LIKE "$1" || system::info::test ID "$1"
}

##

system.info.id() {
  system::info::id "$@"
}
system::info::id() {
  system::info::test "ID" "$1"
}

##

system.info.name() {
  system::info::name "$@"
}

system::info::name() {
  system::info::test "NAME" "$1"
}

##

system.info.version() {
  system::info::version "$@"
}

system::info::version() {
  system::info::test "VERSION_ID" "$1"
}

##

system.info.codename() {
  # what system version are we?
  # when would this matter?
  # I mean, sometimes?
  system::info::test "VERSION_CODENAME" "$1"
}

##

system.info.arch() {
  system::info::arch "$@"
}
system::info::arch() {
  system::info::test "ARCH" "$1"
}

##

system.info.nodename() {
  system::info::nodename "$@"
}

system::info::nodename() {
  system::info::test "NODENAME" "$1"
}
