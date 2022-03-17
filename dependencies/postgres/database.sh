postgres.database.create() {
  local _database=$1; shift

  while getopts "o:" opt; do
    case "$opt" in
      o)
        local owner=$OPTARG;;
    esac
  done
  unset OPTIND
  unset OPTARG
  __babashka_log "${FUNCNAME[0]} $_database"
  function is_met() {

    /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "SELECT 1 FROM pg_database WHERE datname='${_database}';" | grep -q 1
    if [[ $? -ne 0 ]]; then
      return 1
    fi

    if [[ "${_owner} " != " " ]]; then
      /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "SELECT pg_catalog.pg_get_userbyid(d.datdba)
        FROM pg_catalog.pg_database d
        WHERE d.datname = '$_database'
        ORDER BY 1;" | grep -q $_owner
      if [[ $? -ne 0 ]]; then
        return 1
      fi
    fi
    # TODO:
    # Password check? Is that even sensible?
    return 0
  }
  function meet() {
    /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "SELECT 1 FROM pg_database WHERE datname='${_database}';" | grep -q 1
    if [[ $? -ne 0 ]]; then
      /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "CREATE DATABASE ${_database};"
    fi
    if [[ "${_owner} " != " " ]]; then
      /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "ALTER DATABASE ${_database} WITH OWNER ${_owner};"
    fi
  }
  process
}

postgres.database.absent() {
  local _database=$1; shift
  __babashka_log "${FUNCNAME[0]} $_database"
  function is_met() {

    /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "SELECT 1 FROM pg_database WHERE datname='${_database}';" | grep -q 1
    if [[ $? -eq 0 ]]; then
      return 1
    fi
    return 0
  }
  function meet() {
    /usr/bin/sudo -iu postgres /usr/bin/psql -tAc "DROP DATABASE ${_database};"
  }
  process
}
