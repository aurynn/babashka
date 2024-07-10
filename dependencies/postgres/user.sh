postgres.user.create() {
  local _user=$1; shift

  # By default, superuser is off
  _superuser=1
  while getopts "sp:" opt; do
    case "$opt" in
      s)
        _superuser=0;;
      p)
        _password=$OPTARG;;
    esac
  done
  unset OPTIND
  unset OPTARG

  __babashka_log "== ${FUNCNAME[0]} $_user"
  function get_id() {
    echo "${_user}"
  }
  function is_met() {
    /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "select 1 from pg_roles where rolname='$_user';" | grep -q 1
    local _user_exists=$?
    if [[ $_user_exists -eq 1 ]]; then
      return 1
    fi
    /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "select usesuper from pg_user where usename = '$_user';" | grep -q "t"
    local _has_superuser=$?
    if [[ $_superuser -eq 0 ]]; then
      if [[ $_has_superuser -ne 0 ]]; then
        # user doesn't have superuser, should
        return 1
      fi
    elif [[ $_has_superuser -eq 0 ]]; then
      # user has superuser, shouldn't
      return 1
    fi
    return 0
  }
  function meet() {
    /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "select 1 from pg_roles where rolname='$_user';" | grep -q 1
    local _user_exists=$?
    if [[ $_user_exists -eq 1 ]]; then
      /usr/bin/sudo -iu postgres /usr/bin/createuser "$_user"
    fi

    # We always assume the password has changed/should be updated
    # hmm
    # actually that's never checked in the `is_met` section
    # TODO: Should we figure out how to do that?
    /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "alter user $_user with encrypted password '${_password}';"

    /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "select usesuper from pg_user where usename = '$_user';" | grep -q "t"

    local _has_superuser=$?

    if [[ $_superuser -eq 0 ]]; then
      if [[ $_has_superuser -eq 1 ]]; then
        /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "ALTER USER $_user WITH SUPERUSER;"
      fi
    elif [[ $_has_superuser -eq 0 ]]; then
      # If the user has super user, but shouldn't
      /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "ALTER USER $_user WITH NOSUPERUSER;"
    fi
  }
  process
}

postgres.user.absent() {
  local _user=$1; shift
  __babashka_log "== ${FUNCNAME[0]} $_user"
  function get_id() {
    echo "${_user}"
  }
  function is_met() {
    /usr/bin/sudo -iu postgres /usr/bin/psql -tAc \
      "select 1 from pg_roles where rolname='$_user';" \
      | grep -q 1
    if [[ $? -eq 1 ]]; then
      return 0
    fi
    return 1
  }
  function meet() {
    /usr/bin/sudo -iu postgres /usr/bin/dropuser "$_user"
  }
  process
}
