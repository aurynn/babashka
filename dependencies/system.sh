function system.group() {
  _group_name=$1; shift

  __babashka_log "== ${FUNCNAME[0]} $_group_name"
  while getopts "g:" opt; do
    case "$opt" in
      # echoing through xargs trims whitespace
      g)
        gid=$(echo $OPTARG | xargs);;
    esac
  done
  # Reset the option parsing
  unset OPTIND
  unset OPTARG
  function get_id() {
    echo "${_group_name}"
  }
  function is_met() {
    if ! getent group $_group_name; then
      return 1
    fi
    if [[ $gid != "" ]]; then
      current_gid=$(getent group ${_group_name} | awk -F ':' '{print $3}')
      if [[ $current_gid != $gid ]]; then
        return 1
      fi
    fi
  }
  function meet() {
    if getent group $_group_name; then
      $__babashka_sudo groupmod -g $gid $_group_name
    else
      $__babashka_sudo addgroup $_group_name ${gid:+-gid $gid}
    fi
  }
  process
}

function system.user() {

  _user_name=$1; shift
  # g: gid or group name
  # u: uid
  # s: system
  # h: homedir
  # l: shell
  # TODO: Use `getopt` instead to allow more betterer parsing?
  #       Though getopt is often confusing
  #       oh well
  while getopts "g:u:l:h:s" opt; do
    case "$opt" in
      g)
        gid=$(echo $OPTARG | xargs);;
      u)
        uid=$(echo $OPTARG | xargs);;
      h)
        homedir=$(echo $OPTARG | xargs);;
      l)
        shell=$(echo $OPTARG | xargs);;
      s)
        is_system=true
    esac
  done
  # Reset the option parsing
  unset OPTIND
  unset OPTARG
  __babashka_log "== ${FUNCNAME[0]} $_user_name"
  if [[ is_system == true ]]; then
    unset $homedir
  fi
  
  function get_id() {
    echo "${_user_name}"
  }
  
  function is_met() {
    # User exists?
    getent passwd ${_user_name} || return 1
    # Group ID is correct?
    if [[ $gid != "" ]]; then
      case $gid in
        *[!0-9]*)
          # Is a string, so we need to check if the group even exists
          # And if it doesn't, that's, well, bad? Yes, that's bad.
          _gid=$(getent group $gid | awk -F ':' '{print $3}')
          ;;
        *)
          # is a number
          # We can pass it on directly
          _gid=$gid
          ;;
      esac
      [[ $(getent passwd ${_user_name} | awk -F ':' '{print $4}') == $_gid ]] || return 1
    fi

    if [[ $uid != "" ]]; then
      [[ $(getent passwd ${_user_name} | awk -F ':' '{print $3}') == $uid ]] || return 1
    fi
    if [[ $shell != "" ]]; then
      [[ $(getent passwd ${_user_name} | awk -F ':' '{print $7}') == $shell ]] || return 1
    fi
    if [[ $homedir != "" ]]; then
      [[ $(getent passwd ${_user_name} | awk -F ':' '{print $6}') == $homedir ]] || return 1
    fi
    # TODO
    # Implement -s, since I'm not sure what that should do
  }
  function meet() {
    case $gid in
      *[!0-9]*)
        # Is a string, so we need to check if the group even exists
        # And if it doesn't, that's, well, bad? Yes, that's bad.
        _gid=$(getent group $gid | awk -F ':' '{print $3}')
        ;;
      *)
        # is a number
        # We can pass it on directly
        _gid=$gid
        ;;
    esac
    if getent passwd ${_user_name} ; then
      # User already exists, so we're modifying the user
      $__babashka_sudo usermod \
        ${_gid:+-g $_gid} \
        ${uid:+-u $uid} \
        ${shell:+-s $shell} \
        ${homedir:+-d $homedir} \
        ${_user_name}
    else
      # User doesn't exist, create it
      $__babashka_sudo useradd \
        ${_gid:+-g $_gid} \
        ${uid:+-u $uid} \
        ${homedir:+-d $homedir -m} \
        ${shell:+-s $shell} \
        ${_user_name}
    fi
  }
  process
}

system.user.groups() {
  _user_name=$1; shift
  # g: gid or group name
  
  # Should this enforce that a user is _only_ part of these groups?
  # hmm.
  # Yeah, yeah I think that's reasonable
  
  
  local _groups=();
  while getopts "g:" opt; do
    case "$opt" in
      g)
        _groups+=( $OPTARG )
    esac
  done
  # Reset the option parsing
  unset OPTIND
  unset OPTARG
  __babashka_log "== ${FUNCNAME[0]} $_user_name"
  getent passwd ${_user_name} > /dev/null || __babashka_fail "${FUNCNAME[0]}: User $_user_name does not exist."
  
  for group in ${_groups[@]}; do
    getent group $group > /dev/null || __babashka_fail "${FUNCNAME[0]}: Group $group does not exist."
  done
  
  function get_id() {
    echo "${_user_name}"
  }
  
  function is_met() {
    
    # We want to look at all the groups, since we've decided that this tool
    # is authoritative on what groups a user is a member of now
    
    # find any places where the user isn't where it should be
    
    for group in "${_groups[@]}"; do
      members=$(getent group $group | awk -F ':' '{print $4}')
      # Make the members into an array that we can iterate over
      members=(${members//,/ })
      if (( ${#members[@]} == 0 )) ; then
        return 1
      fi
      for member in ${members[@]}; do
        if [[ $member == $_user_name ]]; then
          continue 2
        fi
      done
      return 1
    done
    
    # Find if the user is in any places it shouldn't be
    
    for group in $( groups ); do
      for ingrp in "${_groups[@]}"; do
        if [[ $ingrp == $group ]]; then
          # We've already checked the should-be-here groups, so we can just
          # continue around to the next iteration of the outer loop of all groups.
          continue 2
        fi
      done
      # get the members of this group
      members=$(getent group $group | awk -F ':' '{print $4}')
      # Make the members into an array  we can iterate over
      members=(${members//,/ })
      for member in ${members[@]}; do
        if [[ $member == $_user_name ]]; then
          return 1
        fi
      done
    done
    # Everything is as it should be
    return 0
  }
  function meet() {
    groups=$(IFS=, ; echo "${_groups[*]}")
    $__babashka_sudo usermod \
      -G $groups \
      ${_user_name}
  }
  process
}