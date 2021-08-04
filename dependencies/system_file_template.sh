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
        _group=$(echo $OPTARG | xargs);;
      o)
        _owner=$(echo $OPTARG | xargs);;
      m)
        _mode=$(echo $OPTARG | xargs);;
      t)
        _template=$(echo $OPTARG | xargs);;
      s)
        # Set a variables file
        _variables=$(echo $OPTARG | xargs);;
    esac
  done
  unset OPTIND
  unset OPTARG
  __babashka_log "system.file.template $_file_name"
  if ! [[ -e /usr/bin/mo ]]; then
    __babashka_fail "system.file.template: template renderer not installed"
  fi
  if [[ $_template == "" ]]; then
    __babashka_fail "system.file.template: template path must be set"
  fi
  if ! [[ -e $_template ]]; then
    __babashka_fail "system.file.template: template $_template does not exist"
    exit -1
  fi

  function is_met() {
    # Basic existence and mode settings
    ! [[ -e $_file_name ]] && return 1

    if [[ $_group != "" ]]; then
      path.has_gid $_file_name $_group || return 1
    fi
    if [[ $_owner != "" ]]; then
      path.has_uid $_file_name $_owner || return 1
    fi
    if [[ $_mode != "" ]]; then
      path.has_mode $_file_name $_mode || return 1
    fi
    # Ensure the contents are what we expect them to be
    # Since this is using a templating engine, we have to render out the
    # template in order to compare it to the on-disk file
    # so let's get rendering
    # I think we have to assume that variables have been set?

    /usr/bin/mo ${variables:+-s=$variables} $_template | $__babashka_sudo diff $_file_name -
  }
  function meet() {

    # Overwrite the file
    /usr/bin/mo ${variables:+-s=$variables} $_template | $__babashka_sudo tee $_file_name
    # Change these settings, if needed
    [[ $_mode != "" ]] && $__babashka_sudo chmod $_mode $_file_name
    [[ $_owner != "" ]] && $__babashka_sudo chown $_owner $_file_name
    [[ $_group != "" ]] && $__babashka_sudo chgrp $_group $_file_name
  }
  process
}
