function system.directory() {
  local _directory=$1;
  shift
  while getopts "o:g:m:" opt; do
    case "$opt" in
      o)
        local owner=$(echo $OPTARG | xargs);;
      g)
        local group=$(echo $OPTARG | xargs);;
      m)
        local mode=$(echo $OPTARG | xargs);;
    esac
  done
  # Reset the option parsing
  unset OPTIND
  unset OPTARG
  __babashka_log "system.directory $_directory"
  # TODO: Support not-Linux?
  function is_met() {
    if ! [[ -d $_directory ]]; then
      return 1
    fi
    if [[ $group != "" ]]; then
      path.has_gid $_directory $group || return 1
    fi
    if [[ $owner != "" ]]; then
      path.has_uid $_directory $owner || return 1
    fi
    if [[ $mode != "" ]]; then
      path.has_mode $_directory $mode || return 1
    fi
    return 0
  }
  function meet() {
    # Create parents automatically
    ! [[ -d $directory ]] && $__babashka_sudo mkdir -p $_directory
    [[ $mode != "" ]] && $__babashka_sudo chmod $mode $_directory
    [[ $owner != "" ]] && $__babashka_sudo chown $owner $_directory
    [[ $group != "" ]] && $__babashka_sudo chgrp $group $_directory
  }
  process
}

# function system.directory.sync() {
#   local _directory=$1;
#   shift
#   while getopts "o:g:m" opt; do
#     case "$opt" in
#       o)
#         local owner=$(echo $OPTARG | xargs);;
#       g)
#         local group=$(echo $OPTARG | xargs);;
#       m)
#         local mode=$(echo $OPTARG | xargs);;
#       s)
#         local _source=$(echo $OPTARG | xargs);;
#     esac
#   done
#   unset OPTIND
#   unset OPTARG
#   __babashka_log "system.directory $_directory"
#   function is_met() {
#
#   }
#   function meet() {
#
#   }
# }
