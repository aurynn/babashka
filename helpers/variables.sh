# Variables resolver

# Provides an interface for querying defined variables, without kits or
# implementations trying to source in files at random from
# `/etc/kitbash/variables`.
# Designed for pluggability of resolvers, so that new resolvers can be added
# without much issue later on.

declare -ag __KITBASH_VAR_RESOLVERS
declare -ag __KITBASH_VAR_SECRET_RESOLVERS

declare -ag __KITBASH_VAR_RESOLVERS_INIT
declare -ag __KITBASH_SECRET_RESOLVERS_INIT


declare -g __KITBASH_LOAD_VARIABLES
__KITBASH_LOAD_VARIABLES=0

# info.var
# Usage: info.var NAME [DEFAULT]
# Lookup precedence:
#   1. Cached value (if already loaded)
#   2. Resolvers as defined in __KITBASH_VAR_RESOLVERS
info.var() {
  local name default value
  name="$1"
  default="${2-}"
  value=""
   
  [[ "$name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || {
    log.error "Invalid variable name: %s" "$name"
    return 1
  }
  
  log.debug "Searching for variable: '$name'"
  
  # Assume that all resolvers will handle their own caching, since trying to
  #   overload logic here to add a cache is silly.
  local resolver exit_code
  for resolver in "${__KITBASH_VAR_RESOLVERS[@]}"; do
    value=$("$resolver" "$name")
    exit_code="$?" # Immediately capture the exit code
    # TODO: Define error codes and use case logic to handle them here or some
    #   sort of exception handler system eventually.
    # ... This project is growing its own OO-style environment. Oops.
    if [[ -n "$value" ]]; then
      printf '%s' "$value"
      return 0
    fi
  done
  
  # 3. Default / error
  if [[ -n "$default" ]]; then
    log.debug "info.var: returning default for '$name'"
    printf '%s\n' "$default"
    return 0
  fi

  log.error "Variable '$name' not found and no default provided."
  return 1
}

info.var.secret() {
  local name resolver val
  name="$1"
  log.debug "Searching for secret '$name'"
  [[ "$name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || {
    log.error "Invalid variable name: %s" "$name"
    return 1
  }
  for resolver in "${__KITBASH_VAR_SECRET_RESOLVERS[@]}"; do
    log.debug "Checking resolver '$resolver'"
    val=$("$resolver" "$name")
    if [[ -n "$val" ]]; then
      printf '%s' "$val"
      return 0
    fi
  done
  return 1
}

# kitbash.vars.reload
# Usage: kitbash.vars.reload
# Used to tell the variable loader that it needs to re-parse the variable
# providers and update the internal cache.
kitbash.vars.reload() {
  __KITBASH_LOAD_VARIABLES=0
}

# kitbash.vars.load
# Usage: kitbash.vars.load NAME
# Attempts to load the variable into cache, in reverse order of declaration in
# __KITBASH_VAR_RESOLVERS, with the last resolver winning.
# Default resolver loads files in /etc/kitbash/variables in ascending lexical
# order.
kitbash.vars.load() {
  # 2. Run through resolvers in order
  local resolver
  local name
  name="$1"
  
  log.debug "Attempting to load variable: '${name}'"
  log.debug "Resolvers: ${__KITBASH_VAR_RESOLVERS[@]}"
  for resolver in "${__KITBASH_VAR_RESOLVERS[@]}"; do
    log.debug "Using resolver: '${resolver}'"
    if declare -F "$resolver" > /dev/null 2>&1; then
      log.debug "'$resolver' is a defined function."
      value="$("$resolver" "$name")" || true
      if [[ -n "$value" ]]; then
        log.debug "info.var: resolved '$name' via $resolver"
        __KITBASH_VAR_CACHE["$name"]="$value"
        printf '%s\n' "$value"
        return 0
      fi
    else
      log.debug "info.var: skipping undefined resolver $resolver"
    fi
  done
  __KITBASH_LOAD_VARIABLES=1
}

kitbash.vars.register_resolver() {
  local function
  function="$1"
  log.debug "Registering resolver: '${function}'"
  local mode
  mode="${2:-prepend}"
  
  case "$mode" in
    prepend)
      log.debug "Prepending '${function}'"
      types.set.prepend __KITBASH_VAR_RESOLVERS "$function"
      ;;
    append|*)
      log.debug "Appending '${function}'"
      types.set.append __KITBASH_VAR_RESOLVERS "$function"
      ;;
  esac
  log.debug "Resolvers now contains: '${__KITBASH_VAR_RESOLVERS[@]}'"
}

kitbash.vars.secrets.register_resolver() {
  local function
  function="$1"
  log.debug "Registering secrets resolver: '${function}'"
  local mode
  mode="${2:-prepend}"
  
  case "$mode" in
    prepend)
      log.debug "Prepending '${function}'"
      types.set.prepend __KITBASH_VAR_SECRET_RESOLVERS "$function"
      ;;
    append|*)
      log.debug "Appending '${function}'"
      types.set.append __KITBASH_VAR_SECRET_RESOLVERS "$function"
      ;;
  esac
  log.debug "Resolvers now contains: '${__KITBASH_VAR_SECRET_RESOLVERS[@]}'"
}


# TODO
# Move this to a function that exports a set of variables out to a file, so
# that that file can then be used by Mo dynamically, instead of a series of
# info.var calls throughout the templates.
kitbash.export() {
  return 1
}

kitbash.vars.init.register() {
  local function
  function="$1"
  log.debug "Registering init: '${function}'"
  local mode
  mode="${2:-prepend}"
  case "$mode" in
    prepend)
      log.debug "Prepending '${function}'"
      types.set.prepend __KITBASH_VAR_RESOLVERS_INIT "$function"
      ;;
    append|*)
      log.debug "Appending '${function}'"
      types.set.append __KITBASH_VAR_RESOLVERS_INIT "$function"
      ;;
  esac
}

kitbash.secrets.init.register() {
  local function
  function="$1"
  log.debug "Registering init: '${function}'"
  local mode
  mode="${2:-prepend}"
  case "$mode" in
    prepend)
      log.debug "Prepending '${function}'"
      types.set.prepend __KITBASH_SECRET_RESOLVERS_INIT "$function"
      ;;
    append|*)
      log.debug "Appending '${function}'"
      types.set.append __KITBASH_SECRET_RESOLVERS_INIT "$function"
      ;;
  esac
}

kitbash.vars.init() {
  local init
  for init in "${__KITBASH_VAR_RESOLVERS_INIT[@]}"; do
    log.debug "Calling $init"
    "$init"
  done
}

kitbash.secrets.init() {
  local init
  for init in "${__KITBASH_SECRET_RESOLVERS_INIT[@]}"; do
    log.debug "Calling secret $init"
    "$init"
  done
}

kitbash.load variables/files.sh
