# Manages a symlink on disk
# Requires that the source exist, obviously
# Do modes make sense for this?

function system.file.symlink() {
  local _source=$1; shift
  local _dest=$1; shift

  __babashka_log "system.file.symlink ${_source} ${_dest}"

  # Source and dest should be absolute paths, not relative
  for _path in $_source $_dest; do
    case $_path in
      (/*)
        pathchk -- "$_path";;
      (*)
        __babashka_fail "${_path} is not absolute"
        ;;
    esac
  done

  is_met() {
    [[ -e ${_dest} && -L ${_dest} ]] && \
      [[ $($__babashka_sudo readlink ${_dest}) == ${_source} ]]
  }
  meet() {
    if ! [[ -e ${_source} ]]; then
      __babashka_fail "${_source} does not exist"
    fi
    if [[ -e ${_dest} ]]; then
      # the destination is NOT a link, so, we should error in this case
      # and let the user manage it directly
      if ! [[ -L ${_dest} ]]; then
        if [[ __babashka_force != "yes" ]]; then
          __babashka_fail "${_dest} exists and is not a symlink; use -f"
          return 1
        fi
        __babashka_log "WARN: ${_dest} exists and is not a symlink; unlinking"
      fi
      $__babashka_sudo rm ${_dest}
    fi
    $__babashka_sudo ln -s ${_source} ${_dest}
  }
  process
}
