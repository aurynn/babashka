function system.directory.git() {
  local _directory=$1; shift;
  __babashka_log "== ${FUNCNAME[0]} $_directory"

  # Fetch a repo from git
  while getopts "o:g:m:s:" opt; do
    case "$opt" in
      o)
        local owner=$(echo $OPTARG | xargs);;
      g)
        local group=$(echo $OPTARG | xargs);;
      m)
        local mode=$(echo $OPTARG | xargs);;
      s)
        local _source=$(echo $OPTARG | xargs);;
      # t)
      #   local _tag=$(echo $OPTARG | xargs);;
    esac
  done
  # Reset the option parsing
  unset OPTIND
  unset OPTARG
  if [[ "$_source " == " " ]]; then
    __babashka_fail "${FUNCNAME[0]} $_directory: Git source must be set with -s"
    exit 1
  fi
  function get_id() {
    echo "${_directory}"
  }
  function is_met() {
    if ! [[ -e $_directory ]]; then
      return 1 # the directory doesn't exist, so, just go
    fi
    if [[ -e $_directory && ! -d $_directory ]]; then
      __babashka_fail "${FUNCNAME[0]} $_directory: path exists, but is not a directory"
      exit 1
    fi
    # check if the directory is a git repo at all...

    /usr/bin/git -C $_directory rev-parse 2>/dev/null
    if [[ $? != 0 ]]; then
      # but this means it's not a git repo, and we don't want to clobber it,
      # so we abort
      __babashka_fail "${FUNCNAME[0]} $_directory: Directory already exists and is not a git repo; aborting"
      exit 1
    fi
    # It _is_ a git repo, so that's cool
    # now check if our source is a valid upstream for this repo
    pushd $_directory
    local _IFS=$IFS
    IFS=$'\n'
    for repo in $(/usr/bin/git remote -v); do
      _name=$(echo $repo | awk '{print $1}' | xargs)
      _url=$(echo $repo | awk '{print $2}' | xargs)
      _type=$(echo $repo | awk '{print $3}' | xargs)
      if [[ $_type == "(fetch)" ]]; then
        if [[ $_url == $_source ]]; then
          # Okay so we have a remote that matches our source! yay!
          # we'll need to ... fetch the remote? and check if we're up to date
          # Not bothering to check anything about what branch or tag we're on or anything
          local _current_branch=$(/usr/bin/git rev-parse --abbrev-ref HEAD)
          __babashka_log $_current_branch
          /usr/bin/git remote update
          if [[ $(git rev-parse HEAD) == $(git rev-parse $_current_branch) ]]; then
            # Everything is fine, and we can assert that things Are Fine
            popd
            IFS=$_IFS
            return 0
          else
            return 1
          fi
        fi
      fi
    done
    popd
    # We couldn't validate that our source is a valid upstream for this repo
    IFS=$_IFS
    __babashka_fail "$_directory: $_source is not a registered upstream"
    # return 1
  }
  function meet() {
    # okay well
    if ! [[ -e $_directory ]]; then
      $__babashka_sudo /usr/bin/git clone $_source $_directory 2>&1 > /dev/null
      [[ $mode != "" ]] && $__babashka_sudo chmod $mode $_directory
      [[ $owner != "" ]] && $__babashka_sudo chown $owner $_directory
      [[ $group != "" ]] && $__babashka_sudo chgrp $group $_directory
      return 0
    fi
    # otherwise, it's an existing directory, and we've already confirmed that
    # we need to fetch, so
    pushd $_directory
    local _IFS=$IFS
    IFS=$'\n'
    for repo in $(/usr/bin/git remote -v); do
      _name=$(echo $repo | awk '{print $1}' | sed -e 's/\n//')
      _url=$(echo $repo | awk '{print $2}' | sed -e 's/\n//')
      _type=$(echo $repo | awk '{print $3}' | sed -e 's/\n//')
      if [[ $_type == "(fetch)" ]]; then
        if [[ $_url != $_source ]]; then
          continue
        fi
      else
          continue
      fi
      local _current_branch=$(/usr/bin/git rev-parse --abbrev-ref HEAD)
      /usr/bin/git pull $_name $_current_branch
      IFS=$_IFS
      return $?
    done
    IFS=$_IFS
    return 1
  }
  process
}
