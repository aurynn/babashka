system.info.id "macos" || return

user.get_uid() {
  local identifier="$1"
  local uid
  if [[ "$identifier" =~ ^[0-9]+$ ]]; then
    # Verifies the UID maps to a user, IE, the user exists, since there's not
    # a way to search by UID directly
    uid=$(dscl . -search /Users UniqueID "$identifier")
    [[ -z "$uid" ]] && return 1
    printf "%s\n" "$identifier"
    return 0
  elif dscl . -read "/Users/$identifier" &>/dev/null; then
    dscl . -read "/Users/$identifier" UniqueID | awk '{print $2}'
    return 0
  else
    return 1
  fi
}

group.get_gid() {
  local identifier="$1"
  local gid
  if [[ "$identifier" =~ ^[0-9]+$ ]]; then
    gid=$(dscl . -search /Groups PrimaryGroupID "$identifier")
    [[ -z "$gid" ]] && return 1
    printf "%s\n" "$identifier"
    return 0
  elif dscl . -read "/Groups/$identifier" &>/dev/null; then
    dscl . -read "/Groups/$identifier" PrimaryGroupID | awk '{print $2}'
  else
    return 1
  fi
}
