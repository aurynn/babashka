# Manages a file on disk somewhere

function system.file() {
  _file_name=$1; shift
  # g: gid or group name
  # u: uid or username
  # s: source (optional)
  # c: contents (optional(?))
  # TODO: Use `getopt` instead to allow more betterer parsing?
  #       Though getopt is often confusing
  #       oh well
  while getopts "g:o:m:s:c:" opt; do
    case "$opt" in
      g)
        group=$(echo $OPTARG | xargs);;
      o)
        owner=$(echo $OPTARG | xargs);;
      m)
        mode=$(echo $OPTARG | xargs);;
      s)
        _source=$(echo $OPTARG | xargs);;
      c)
        contents=$(echo $OPTARG | xargs);;
    esac
  done
  unset OPTIND
  unset OPTARG
  __babashka_log "system.file $_file_name"

  function is_met() {
    ! [[ -e $_file_name ]] && return 1

    if [[ $group != "" ]]; then
      path.has_gid $_file_name $group || return 1
    fi
    if [[ $owner != "" ]]; then
      path.has_uid $_file_name $owner || return 1
    fi
    if [[ $mode != "" ]]; then
      path.has_mode $_file_name $mode || return 1
    fi
    # Okay the basic mode stuff is set up properly
    # (though ideally this'd be a helper function instead of C&P from system.directory)
    # TODO I guess?
    # Okay anyway check contents now

    if [[ $_source != "" ]]; then
      # okay we're using source
      # We might need sudo privs to read the file
      $__babashka_sudo diff $_file_name $_source
      return $?
    elif [[ $contents != "" ]]; then
      # Use contents
      # We might need sudo privs to read the file
      echo $contents | $__babashka_sudo diff $_file_name -
      return $?
    else
      # that's an error, at least one of these needs to be set
      __babashka_fail "system.file: one of source or contents must be set"
    fi
    return 0
  }
  function meet() {
    if [[ $_source != "" ]]; then
      $__babashka_sudo cp $_source $_file_name
    else
      # Do it quietly
      echo $contents | $__babashka_sudo tee $_file_name > /dev/null
    fi
    [[ $mode != "" ]] && $__babashka_sudo chmod $mode $_file_name
    [[ $owner != "" ]] && $__babashka_sudo chown $owner $_file_name
    [[ $group != "" ]] && $__babashka_sudo chgrp $group $_file_name
  }
  process
}
