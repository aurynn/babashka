# A templated file
# Expects/needs a template renderer of some variety


system.file.template() {
  # path to manage
  _file_name=$1; shift

  # g: gid or group name
  # o: uid or username
  # t: template
  while getopts "g:o:m:t:s:" opt; do
    case "$opt" in
      g)
        group=$(echo $OPTARG | xargs);;
      o)
        owner=$(echo $OPTARG | xargs);;
      m)
        mode=$(echo $OPTARG | xargs);;
      t)
        template=$(echo $OPTARG | xargs);;
      s)
        # Set a variables file
        variables=$(echo $OPTARG | xargs);;
    esac
  done
  unset OPTIND
  unset OPTARG
  __babashka_log "system.file.template $_file_name"
  if ! [[ -e /usr/bin/mo ]]; then
    __babashka_log "ERROR: system.file.template: template renderer not installed"
    exit -1
  fi
  if [[ $template == "" ]]; then
    __babashka_log "ERROR: system.file.template: template path must be set"
    exit -1
  fi
  if ! [[ -e $template ]]; then
    __babashka_log "ERROR: system.file.template: template $template does not exist"
    exit -1
  fi

  function is_met() {
    # Basic existence and mode settings
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
    # Ensure the contents are what we expect them to be
    # Since this is using a templating engine, we have to render out the
    # template in order to compare it to the on-disk file
    # so let's get rendering
    # I think we have to assume that variables have been set?

    /usr/bin/mo ${variables:+-s=$variables} $template | $__babashka_sudo diff $_file_name -
  }
  function meet() {

    # Overwrite the file
    /usr/bin/mo ${variables:+-s=$variables} $template | $__babashka_sudo tee $_file_name
    # Change these settings, if needed
    [[ $mode != "" ]] && $__babashka_sudo chmod $mode $_file_name
    [[ $owner != "" ]] && $__babashka_sudo chown $owner $_file_name
    [[ $group != "" ]] && $__babashka_sudo chgrp $group $_file_name
  }
  process
}
