# A templated file
# Expects/needs a template renderer of some variety

# Brings in the template renderer, if it's been installed to the expected
# location.
# Needed so we can run functions in the templates.
[[ -e /usr/bin/mo && -f /usr/bin/mo ]] && . /usr/bin/mo

system.file.template() {
  # path to manage
  local _file_name=$1; shift

  # g: gid or group name
  # o: uid or username
  # t: template
  
  # Declare the array that'll hold our values
  # local _vararray=()
  local -a sources
  
  
  declare -A OPTIONS=(
    ["-m|--mode;mode"]="0755"
    ["-o|--owner;string"]="root"
    ["-g|--group;string"]="root"
    ["-t|--template;file"]=""
    ["--open;string"]="{{"
    ["--close;string"]="}}"
  )
  
  local -A options
  
  std.argparser options "$@" || {
    log.error "Could not parse options"
    return 1
  }
  
  local _group _owner _mode _template _open _close
  
  _owner="${options["--owner"]}"
  _group="${options["--group"]}"
  _mode="${options["--mode"]}"
  _template="${options["--template"]}"
  
  _open="${options["--open"]}"
  _close="${options["--close"]}"
  
  
  __babashka_log "== ${FUNCNAME[0]} $_file_name"
  # Ughhhhh this is wrong
  # Do I need a config file for this?
  if ! [[ -e /usr/bin/mo ]]; then
    __babashka_fail "${FUNCNAME[0]}: template renderer mo not installed."
  fi
  
  # Find all the Mo helpers so we can inject them as sources
  # Assumes, based on using the default installer, that any helpers
  #   will be in /etc/babashka/helpers/mo.
  # TODO: Make this configurable?
  local helper
  
  # TODO: Move this out of the function, since it only needs to run once
  local pth dir
  for pth in "${KITBASH_LIBRARY_PATHS[@]}"; do
    dir="$pth/mo"
    if [[ -e "$dir" && -d "$dir" ]]; then
      for helper in $(find "$dir" -name "*.sh"); do
        # __helpers="-s=${__helper} ${__helpers}"
        sources+=("-s=$helper")
      done
    fi
  done
  
  get_id() {
    printf "%s\n" "${_file_name}"
  }
  
  # Strip all unnecessary whitespace
  # mo_cmd=$(normalize "$mo_cmd")
  local contents status tmp
  local orig_umask
  orig_umask=$(umask)
  log.debug mo -u -x --open "$_open" --close "$_close" --fail-on-file --allow-function-arguments "${sources[@]}" "$_template"
  
  # Use `mo` instead of /usr/bin/mo so that it uses the sourced-in function
  # for Mo instead of trying to shell out. This is so that Mo has access to
  # our internal functions for info.var and info.var.secret.
  mo_cmd=(mo -u -x --open "$_open" --close "$_close" --fail-on-function --fail-on-file --allow-function-arguments "${sources[@]}" "$_template")
  
  umask 077
  tmp=$(mktemp "$_file_name".tmpl.XXXXXXXX) || {
    umask "$orig_umask"
    kitbash.fail "Could not create template tmpfile"
  }
  umask "$orig_umask"
  
  if "${mo_cmd[@]}" >"$tmp"; then
    # contents="$(<"$tmp")"
    status=0
  else
    status=$?
  fi
  
  is_met() {
    # Basic existence and mode settings
    [[ "$status" == "0" ]] || return "$status"
    std.file.check "$_file_name" \
      source "$tmp" \
      group "${_group:-root}" \
      owner "${_owner:-root}" \
      mode "${_mode:-644}" || return 1

  }
  meet() {
    [[ "$status" == "0" ]] || return "$status"
    std.file.update "$_file_name" \
      source "$tmp" \
      group "${_group:-root}" \
      owner "${_owner:-root}" \
      mode "${_mode:-644}" || return 1
      
  }
  finally() {
    log.debug "Removing temporary file"
    emit apply "Removing temporary file"
    rm -f "$tmp"
  }
  process "${FUNCNAME[0]}" "$_file_name"
}
