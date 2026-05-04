system.info.test "KERNEL" "linux" || return

user.get_uid() {
  local user
  user="$1"
  [[ -z "$user" ]] && return 1
  
  # Bypass logic
  # If we're a number, we don't need to be looked up
  if [[ "$user" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$user"
    return 0
  fi
  
  local entry
  entry=$(getent passwd "$user") || {
    log.debug "could not getent passwd $user"
    return 1
  }
  
  local name passwd uid gid gecos home shell
  IFS=':' read -r name passwd uid gid gecos home shell <<< "$entry"
  
  printf '%s\n' "$uid"
}

group.get_gid() {
  local grp name passwd gid members
  grp="$1"
  
  [[ -z "$grp" ]] && return 1
  
  # Bypass logic
  # If we're a number, we don't need to be looked up
  if [[ "$grp" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$grp"
    return 0
  fi
  
  local entry
  entry=$(getent group "$grp") || {
    log.debug "could not getent group $grp"
    return 1
  }
  IFS=':' read -r name passwd gid members <<< "$entry"
  
  printf '%s\n' "$gid"
}

