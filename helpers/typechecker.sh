## Provides a typechecker, for use with std.argparser
## Currently provides:
## - str|string
## - int|integer
## - bool|boolean
## - mode
## - file
## - path (uses pathchk)
## - ipaddr (ipv4 only)
std.typecheck() {
  local type="$1"
  local value="$2"
  
  case "$type" in
    str|string)
      # For strings, just check if it's non-empty
      [[ -n "$value" ]] || return 1
      ;;
    int|integer)
      # Check if it's an integer
      [[ "$value" =~ ^-?[0-9]+$ ]] || return 1
      ;;
    bool|boolean)
      # Check if it's a valid boolean (true/false)
      
      # If it's a string type of thing, we can return valid
      # We should normalize the value down to lowercase if possible
      value=$(std.casefold "$value")
      [[ "$value" == "true" || "$value" == "false" ]] && return 0
      # t or f should also be truthy or falsy
      [[ "$value" == "t" || "$value" == "f" ]] && return 0
      
      # If it's not a number type of thing, we can return invalid
      (( "$value" == 0 || "$value" == 1 )) || return 1
      ;;
    mode)
      # Validate unix mode (either numeric or symbolic)
      regex="[ugoa]*[+-=][rwxst]*"
      if [[ "$value" =~ ^[0]{0,1}[0-7]{3}$ || "$value" =~ ^($regex)(,$regex)*$ ]]; then
          return 0
      fi
      return 1
      ;;
    file)
      # Check if it's a valid file path and if the file exists
      if [[ -f "$value" && -e "$value" ]]; then
        return 0
      fi
      return 1
      ;;
    path)
      # Check if it's a valid path-like object, using system-provided
      #   pathchk
      # on Alpine systems, this needs to be installed from coreutils before
      #   it's available
      # Doesn't check if it's actually a valid path.
      # ... should it?
      if /usr/bin/pathchk -p "$value" &> /dev/null; then
        return 0
      fi
      return 1
      ;;
    ipaddr|ipv4)
      # should match valid IPv4 addresses
      segment="[1-2]{1}[0-9]{1}[0-9]{1}|[1-2]{1}[0-9]{1}|[1-2]{1}"
      if [[ "$value" =~ ^$segment\.$segment\.$segment\.$segment ]]; then
        return 0
      fi
      return 1
      # otherwise, attempt to match valid ipv6 addresses?
      ;;
    # TODO
    # - semver
    # - ipv6
    *)
      # If type is unknown, return an error
      echo "Unknown type: $type"
      return 1
      ;;
  esac
  
  ## todo:
  ## Provide a 
  
  return 0
}