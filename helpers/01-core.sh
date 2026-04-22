## Provides some core functionality for use in Babashka

### Globals
__STR_CASEFOLD_LOCALE=""

bb.core.element_in_array() {
  # search for thing in array, which will now be "$@"
  # Exists to make Bash a bit more other languages
  local element
  element="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$element" ]] && return 0
  done
  return 1
}

in_array() {
  bb.core.element_in_array "$@"
}

types.array.exists() {
  if ! declare -p "$1" | grep -q 'declare -a'; then
    log.error "Undefined array '$1'."
    return 1
  fi
}

types.hash.exists() {
  if ! declare -p "$1" | grep -q 'declare -A'; then
    log.error "Undefined associative array '$1'."
    return 1
  fi
}

# TODO
# Move this to a dedicated "types" library
types.array.contains() {
  types.array.exists "$1" || return 1
  local -n array
  local element
  array="$1"
  element="$2"
  local item
  log.debug "Checking array '$1' for '$element'"
  log.debug "Array contains: ${array[@]}"
  for item in "${array[@]}"; do
    [[ "$item" == "$element" ]] && return 0
  done
  # Didn't find it, so, say so.
  return 1
}

types.array.reverse() {
  types.array.exists "$1" || return 1
  local -n _source="$1"
  local i
  log.debug "Reversing array $1"
  log.debug "array contents: ${_source[@]}"
  for ((i=${#_source[@]}-1; i>=0; i--)); do
    log.debug "Emitting ${_source[$i]}"
    printf '%s\n' "${_source[$i]}"
  done
}

types.array.reverse.into() {
  if ! types.array.exists "$1"; then
    log.error "Source array does not exist: '$1'"
    return 1
  fi
  
  if ! types.array.exists "$2"; then
    log.error "Destination array does not exist: '$2'"
    return 2
  fi
  local -n src
  local -n dst
  src="$1"
  dst="$2"
  local i len
  log.debug "Reversing array $1"
  len="${#src[@]}"
  # One less than length
  log.debug "Length: $len"
  (( len-- )) || true
  for ((i="$len"; i>=0; i--)); do
    log.debug "copying ${src[$i]}"
    dst+=("${src["$i"]}")
  done
}

contains() {
  types.array.contains "$@"
}

##
## sets
## Similar to arrays or hashes, but obviously different
##

types.set.append() {
  types.array.exists "$1" || return 1
  local value
  if [[ -z "$1" ]]; then
    log.debug "Missing set name in types.set.append"
    return 1
  fi
  if [[ -z "$2" ]]; then
    log.debug "Missing value in types.set.append"
    return 1
  fi
  local -n arr
  arr="$1"
  value="$2"
  # Pass only the name, not the full array via our nameref
  if contains "$1" "$value"; then
    log.debug "Set '$1' contains '$value'"
    return 0
  fi
  # arr["${#arr[@]}"]="$value"
  arr+=("$value")
  log.debug "Set now contains: '${arr[@]}'"
}

types.set.prepend() {
  types.array.exists "$1" || return 1
  local value
  if [[ -z "$1" ]]; then
    log.debug "Missing set name in types.set.prepend"
  fi
  if [[ -z "$2" ]]; then
    log.debug "Missing value in types.set.prepend"
  fi
  local -n arr="$1"
  value="$2"
  # Pass only the name, not the full array via our nameref
  if contains "$1" "$value"; then
    log.debug "Set '$1' contains '$value'"
    return 0
  fi
  arr=("$value" "${arr[@]}")
}

array.pop() {
  types.array.exists "$1" || return 1
  local last_index
  last_index=$(( ${#arr[@]} - 1 ))
  local -n arr
  arr="$1"
  
  # Handle empty array
  (( last_index < 0 )) && return 1
  
  local value=${arr[$last_index]}
  unset 'arr[last_index]'
  echo "$value"
}

# 
types.assoc.copy() {
  local src_name dst_name key
  src_name="$1"
  dst_name="$2"
  if ! declare -p "$src_name" 2>/dev/null | grep -q 'declare -A'; then
    emit error "No such source '$src'"
    return 1
  fi
  if ! declare -p "$dst_name" 2>/dev/null | grep -q 'declare -A'; then
    emit error "No such destination '$dst'"
    return 2
  fi
  local -n src
  local -n dst
  src="$src_name"
  dst="$dst_name"
  for key in "${src[@]}"; do
    dst["$key"]="${src["$key"]}"
  done
}

str.dot_to_underscore() {
  local str
  str="$*"
  str="$(str.normalize "$str")"
  str="$(str.casefold "$str")"
  printf '%s\n' "${str//./_}"
}

##
## string helpers
##

kitbash.str.normalise() {
  local raw value
  raw="$*"
  # Collapse all whitespace to single spaces
  value="$(printf '%s' "$raw" | tr -s '[:space:]' ' ')"
  value="${value#"${value%%[![:space:]]*}"}" # Trim leading whitespace
  value="${value%"${value##*[![:space:]]}"}" # ... and trailing
  printf '%s\n' "$value"
}

bb.core.normalise_string() {
  kitbash.str.normalise "$@"
}

bb.core.normalize_string() {
  kitbash.str.normalise "$@"
}

normalize() {
  kitbash.str.normalise "$@"
}

str.normalize() {
  kitbash.str.normalise "$@"
}

##

bb.core.casefold() {
  local raw locale
  raw="$1"
  # See if we can find a UTF-8 locale, in order to ensure a broader range of
  #   characters that can or should be folded down.
  # Doesn't handle the full range of unicode characters that *might* need to
  #   be folded, but this should cover most use cases for a configuration
  #   management too, right?
  # Finally, fall into the basic C locale if we can't find a UTF-8 locale to
  #   use.
  if [[ -z "$__STR_CASEFOLD_LOCALE" ]]; then
    # Try to default to the standard C locale
    __STR_CASEFOLD_LOCALE="C"
    local locales
    # Performance optimization, only fetch locales once instead of fetching
    # the whole list on every cycle through the loop.
    locales="$(locale -a 2>/dev/null)"
    # TODO: Generate OS-specific locales that get loaded in at runtime in
    #   order to ensure that this particular locale set isn't the only 
    #   one we try to use.
    for loc in C.UTF-8 C.utf8 en_US.utf8 en_US.UTF-8 UTF-8 C; do
      if grep -qi -x -- "$loc" <<<"$locales"; then
        # Optimization, cache the locale once across the entire run of Kitbash
        __STR_CASEFOLD_LOCALE="$loc"
        break
      fi
    done
  fi
  locale="$__STR_CASEFOLD_LOCALE"
  # Shelling out to awk for this is perhaps not ideal, but it does provide
  # somewhat better syntax for folding all capital letters down to their 
  # lowercase equivalents in our given locale.
  LC_ALL="$locale" awk 'BEGIN {
    str = ARGV[1];
    ARGV[1] = "";
    print tolower(str)
  }' "$raw"
}

std.casefold() {
  bb.core.casefold "$*"
}
str.casefold() {
  bb.core.casefold "$*"
}

## Load a file, relative to the callsite

kitbash.load() {
  local path
  path="$1"
  local src base target
  
  # If we weren't passed a file, then we can't do anything
  if [[ -z "$path" ]]; then
    # TODO:
    # use log.error instead
    log.error "missing path"
    return 1
  fi
  
  # If it's an absolute path and a file we can read we can just short-circuit
  # the entire resolution path and immediately source the file.
  if [[ "$path" == /* && -f "$path" ]]; then
    . "$path"
    return 0
  fi
  
  # Otherwise, we want to resolve from our callsite, not from this callsite.
  # If we're running under the test suite, since BATS rearranges call paths
  # and such, we need to explicitly declare where it is we are being run
  # *from* so that resolution proceeds as expected.
  src="${KITBASH_TEST_CALLER:-"${BASH_SOURCE[1]}"}"
  # Resolve our current location, while also resolving through symlinks. This
  # ensures that we're able to accurately construct paths later on for fully
  # relative file lookups.
  while [[ -h "$src" ]]; do
    local dir
    dir="$(cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd)"
    log.debug "loop dir $dir"
    src="$(readlink "$src")"
    # Are we still not an absolute path?
    [[ "$src" != /* ]] && src="$dir/$src"
  done
  base="$(cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd)"
  
  # If we've been passed an absolute path, then we don't care what our 
  # callsite was.
  if [[ "$path" == /* ]]; then
    target="$path"
  else
    # In all other cases, we want to resolve relative to the caller's callsite
    # and not our own 
    target="$base/$path"
  fi
  # Finally, check if we have a file at all to source in.
  if [[ -f "$target" ]]; then
    # uses . as the more correct syntactic style, instead of `source`
    # shellcheck source=/dev/null
    . "$target"
  else
    log.error "file not found: $target"
    return 1
  fi
}

# kitbash.path
# Usage: kitbash.path
# Returns the CWD of the calling function
kitbash.path() {
  local src
  local depth
  depth="$1"
  [[ -z "$depth" ]] && depth="1"
  # We want to resolve from our callsite, not from this callsite.
  # If we're running under the test suite, since BATS rearranges call paths
  # and such, we need to explicitly declare where it is we are being run
  # *from* so that resolution proceeds as expected.
  src="${KITBASH_TEST_CALLER:-${BASH_SOURCE["$depth"]}}"
  log.debug "Checking context of $src"
  
  while [[ -h "$src" ]]; do
    local dir
    dir="$(cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd)"
    echo "loop dir $dir"
    src="$(readlink "$src")"
    # Are we still not an absolute path?
    [[ "$src" != /* ]] && src="$dir/$src"
  done
  base="$(cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd)"
  echo "$base"
}

# kitbash.file
# Usage: kitbash.file PATH
# PATH: string
# Returns the fully-qualified path to a file on disk, using the resolution
# order of kit-provided default and then local override.
kitbash.file() {
  local request_path relative_path dir lookup_path dir
  declare -a lookup_paths
  lookup_paths=("${KITBASH_LOCAL_PATHS[@]}" "${KITBASH_FILE_RESOLUTION_PATHS[@]}")
  request_path="$1"
  
  if [[ -z "$request_path" ]]; then
    log.error "No defined path"
    return 1
  fi
  
  # Strip leading /, if any
  relative_path="${request_path#/}"
  log.debug "Searching for $relative_path"
  
  local current_model current_kit test_path
  # TODO: Should we even bother with these functions? Hm.
  # current_model="$KITBASH_CURRENT_MODEL"
  current_kit="$KITBASH_CURRENT_KIT"
  
  # log.debug "Current model: '$KITBASH_CURRENT_MODEL'"
  log.debug "Current kit: '$KITBASH_CURRENT_KIT'"
  
  # Extend the lookup paths with the model and kit paths
  # Uses loops as kit and model paths do lookup both at the system level but
  # also allow for kits to be present in the CWD, which should allow for
  # overriding to work as maybe expected.
  
  for dir in "${KITBASH_KIT_PATHS[@]}"; do
    lookup_paths+=( "$dir/$current_kit" )
  done
  
  for dir in "${lookup_paths[@]}"; do
    log.debug "checking path: '$dir/files'"
    if ! [[ -e "$dir/files" ]]; then
      log.debug "Missing files directory: '$dir/files'"
      continue
    fi
    if ! [[ -d "$dir/files" ]]; then
      log.debug "Not a directory: '$dir/files'"
      continue
    fi
    log.debug "Found directory: $dir"
    log.debug "Checking '$dir/files/$relative_path'"
    if [[ -e "$dir/files/$relative_path" && -f "$dir/files/$relative_path" ]]; then
      log.debug "Found file"
      printf "%s/files/%s\n" "$dir" "$relative_path"
      return 0
    fi
  done
  
  emit error "Could not find file: $request_path"
  return 1
}