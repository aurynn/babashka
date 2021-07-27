# does this create a function? is that how this works? How does this even work?

user.get_uid() {
  _user=$1; shift

  if [[ $_user != "" ]]; then
    case $_user in
      *[!0-9]*)
        # Is a string, so we need to check if the group even exists
        # And if it doesn't, that's, well, bad? Yes, that's bad.
        _uid=$(getent passwd $_user | awk -F ':' '{print $3}')
        ;;
      *)
        # is a number
        # We can pass it on directly
        _uid=$_user
        ;;
    esac
    echo $_uid
  else
    # If it's blank then we can't do anything useful
    return -1
  fi
}

group.get_gid() {
  _group_name=$1; shift
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
    echo $_gid
  fi
  return -1
}

path.has_uid() {
  _path=$1; shift
  _uid=$1; shift
  _owner=$(user.get_uid $_uid)
  # UID could be either a username _or_ a UID
  # So we should resolve that
  if [[ $_owner != "" ]] && [[ `stat -c '%u' ${_path}` != $_owner ]]; then
    return 1
  fi
  return 0
}

path.has_gid() {
  _path=$1; shift
  _gid=$1; shift
  _group=$(group.get_gid $_gid)
  # UID could be either a username _or_ a UID
  # So we should resolve that
  if [[ $_group != "" ]] && [[ `stat -c '%g' ${_path}` != $_group ]]; then
    return 1
  fi
  return 0
}

path.has_mode() {
  _path=$1; shift
  _mode=$1; shift
  if [[ ${_mode:0:1} == "0" ]]; then
    # Strip the leading 0, as it's implied
    mode="${_mode:1}"
  fi
  [[ `stat -c '%a' ${_path}` != $_mode ]] && return 1
  return 0
}
