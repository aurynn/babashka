## Provides some core functionality for use in Babashka

bb::core::element_in_array() {
  # search for thing in array, which will now be "$@"
  # Exists to make Bash a bit more other languages
  local element="$1"; shift
  local item
  for item in "$@"; do
    [[ "$item" == "$element" ]] && return 0
  done
  return 1
}

bb::core::normalise_string() {
  local raw="$1"
  # Collapse all whitespace to single spaces
  local value
  value="$(echo "$raw" | tr -s '[:space:]' ' ')"
  value="${value#"${value%%[![:space:]]*}"}" # Trim leading whitespace
  value="${value%"${value##*[![:space:]]}"}" # ... and trailing
  echo "$value"
}

bb::core::casefold() {
  local raw="$1"
  local locale
  # See if we can find a UTF-8 locale, in order to ensure a broader range of
  #   characters that can or should be folded down.
  # Doesn't handle the full range of unicode characters that *might* need to
  #   be folded, but this should cover most use cases for a configuration
  #   management too, right?
  # Finally, fall into the basic C locale if we can't find a UTF-8 locale to
  #   use.
  for loc in C.UTF-8 en_US.UTF-8 UTF-8 C; do
    if locale -a 2>/dev/null | grep -qi "^${loc}$"; then
      locale="$loc"
      break
    fi
  done
  
  LC_ALL="$locale" awk 'BEGIN {
    str = ARGV[1];
    ARGV[1] = "";
    print tolower(str)
  }' "$raw"
}