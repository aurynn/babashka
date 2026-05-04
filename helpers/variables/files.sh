# Variables file loader

declare -Ag __KITBASH_VAR_FILE_CACHE
declare -Ag __KITBASH_SECRET_FILE_CACHE

# Load from general variables files
kitbash.vars.register_resolver kitbash.vars.files.lookup append
# The variables init, since it assumes that it'll be caching.
kitbash.vars.init.register kitbash.vars.files.init
kitbash.secrets.init.register kitbash.vars.files.init
# Load from secrets variables files
kitbash.vars.secrets.register_resolver kitbash.vars.files.secret append

# declare -ag __KITBASH_CHECKED_FILES
# declare -g __KITBASH_LOAD_FILES
# __KITBASH_LOAD_FILES=1

# Load files on init, so we're not doing silly searching on each run through.
# Caches directly, since that's more sensible than having a global cache, and
#   we can more sensibly use the resolver chain to ensure that the right value
#   is getting returned.
# This does result in some wasted work, but, enh.
kitbash.vars.files.init() {
  local fn
  
  # IFS= sets IFS to \0 instead of \n, which lets more complex values through
  # if need be.
  while IFS= read -r -d '' fn; do
    log.debug "reading $fn into variable cache"
    kitbash.vars.files.read_into "$fn" "__KITBASH_VAR_FILE_CACHE"
  done < <(kitbash.vars.files.list0 KITBASH_VARIABLE_PATHS)
}

kitbash.secrets.files.init() {
  local fn
  log.debug "Initializing secrets cache"
  log.debug "Using ${KITBASH_SECRET_PATHS[@]}"
  while IFS= read -r -d '' fn; do
    log.debug "reading $fn into secret cache"
    kitbash.vars.files.read_into "$fn" "__KITBASH_SECRET_FILE_CACHE"
  done < <(kitbash.vars.files.list0 KITBASH_SECRET_PATHS)
}

# kitbash.vars.files.general
# Usage: kitbash.vars.files.general NAME
# Reloads all the variables files in __KITBASH_VARIABLES_PATH in ascending
# lexical order into the private hash __KITBASH_VAR_CACHE.
# Takes NAME to provide an interface for info.var lookup
kitbash.vars.files.lookup() {
  local name
  name="$1"
  
  log.debug "Checking '$name'"
  log.debug "${__KITBASH_VAR_FILE_CACHE["$name"]}"
  # Requires Bash >=5.2
  if [[ -v __KITBASH_VAR_FILE_CACHE["$name"] ]]; then
    printf '%s\n' "${__KITBASH_VAR_FILE_CACHE["$name"]}"
    return
  fi
  return 1
}

kitbash.vars.files.list0() {
  local -n paths
  paths="$1"
  log.debug "Reading from $1"
  local model directory models_d fn suffix
  local -a search_paths
  
  local -a model_files_find_query
  local -a glob_find_query
  
  # Generate the list of possible model filenames once.
  # for model in "${__KITBASH_MODEL_TREE_STACK[@]}"; do
  #   for suffix in "${KITBASH_VARIABLE_SUFFIXES[@]}"; do
  #     model_files_find_query+=(-name "$model.$suffix" -or)
  #   done
  #   # Strip the last -o since it'll error otherwise.
  #   unset 'model_find_query[-1]'
  # done
  
  for suffix in "${KITBASH_VARIABLE_SUFFIXES[@]}"; do
    glob_find_query+=(-name "*.$suffix" -o)
  done
  (( "${#glob_find_query[@]}" == 0 )) || {
    # Strip the last "-or" since it's an error.
    unset glob_find_query[-1]
  }
  log.debug "Glob query: '${glob_find_query[@]}'"
  
  # Generate the model files list first
  kitbash.vars.files.model.list0
  
  # Recombine discovered search paths with original incoming paths, with the
  #   understanding that any already-defined items will be skipped by the
  #   parser due to already being cached.
  log.debug "Finding generic variable files"
  search_paths=("${search_paths[@]}" "${paths[@]}")
  unset directory
  for directory in "${search_paths[@]}"; do
    [[ -e "$directory" && -d "$directory" ]] || continue
    log.debug "Searching path $directory"
    find -L "$directory" -maxdepth 1 -type f \( "${glob_find_query[@]}" \) -print0 | sort -znr
  done
}

kitbash.vars.files.model.list0() {
  local model suffix
  declare -a model_files_find_query
  declare -a glob_find_query
  
  # Generate the list of valid suffixes to search for in the 
  #  models.d/modelname directories
  
  for suffix in "${KITBASH_VARIABLE_SUFFIXES[@]}"; do
    glob_find_query+=(-name "*.$suffix" -o)
  done
  (( "${#glob_find_query[@]}" == 0 )) || {
    # Strip the last "-or" since it's an error.
    unset glob_find_query[-1]
  }
  
  # Generate a list of filenames ala model.sh, model.bash, etc.
  
  log.debug "Model stack: '${__KITBASH_MODEL_TREE_STACK[@]}'"
  
  [[ -n "$KITBASH_CURRENT_MODEL" ]] || {
    log.warn "No model set."
    return 0
  }
  
  (( "${#__KITBASH_MODEL_TREE_STACK[@]}" == 0 )) && {
    # There's no models to check over, so we can just return.
    log.warn "No model stack established."
    return 0
  }
  
  for model in "${__KITBASH_MODEL_TREE_STACK[@]}"; do
    for suffix in "${KITBASH_VARIABLE_SUFFIXES[@]}"; do
      model_files_find_query+=(-name "$model.$suffix" -o)
    done
  done
  # Strip the last -o since it'll error otherwise.
  (( "${#model_files_find_query[@]}" >= 1 )) && {
    unset model_files_find_query[-1]
  }
  log.debug "query: '${model_files_find_query[@]}'"
  
  # Generates the list of search paths
  # ${paths[@]} exists in scope because it's from our caller's scope.
  # This is obviously *really* brittle and shouldn't be done.
  # TODO: Fix this brittle-ass code.
  for directory in "${paths[@]}"; do
    [[ -e "$directory" && -d "$directory" ]] || continue
    models_d="$directory"/"$KITBASH_MODELS_DIRECTORY_NAME"
    log.debug "Checking models directory $models_d"
    
    [[ -e "$models_d" ]] || {
      log.debug "$models_d does not exist."
      continue
    }
    
    # The first model loaded is the model we're examining, always.
    # Then it proceeds down the tree to subsequent models, to see if they have
    # defined any variable files, to allow for models to provide a default
    # definition for any given variable.    
    for model in "${__KITBASH_MODEL_TREE_STACK[@]}"; do
      log.debug "Adding '$model' to search path"
      
      # This will be like model.d/model_name, where we want to grab *.sh, *.bash, etc.
      model_path="$models_d/$model"
      
      # If a current model is defined, we want to scope our variable lookups
      # to that.
      # That means we'll either load up a file with the model's name AND/OR
      # all the files in the directory with the model's name.
      
      if [[ -e "$model_path" && -d "$model_path" ]]; then
        log.debug "Adding to search path: '$model_path'"
        search_paths+=("$model_path")
      fi
      # Now, look in the models.d directory for any files named for the model
      # we're looking at.
    done
    # The literal models files, if any, come afterwards.
    # Uses \(\) to group all the name OR statements together.
    # This searches through all the explicitly-named model filenames *first*,
    #   before moving on to the model-specific directories.
    # ... Though maybe they should take priority...?
    # ... should figure that out.
    log.debug "Finding model files in $models_d"
    find -L "$models_d" -maxdepth 1 -type f \( "${model_files_find_query[@]}" \) -print0
  done
}

# kitbash.vars.files.secret
# Returns a secret based on the provided key
# Uses a cache, since re-reading secrets for every invocation is quite
#   wasteful, even on modern machines.
kitbash.vars.files.secret() {
  local name
  name="$1"
  log.debug "Searching for secret: '$name'"
  
  if [[ -v __KITBASH_SECRET_FILE_CACHE["$name"] ]]; then
    printf '%s\n' "${__KITBASH_SECRET_FILE_CACHE["$name"]}"
    return
  fi
  emit error "No such secret '$name'"
  return 1
}

# Read in and parse k=v files into a provided hash.
# Allows for easy re-use of k=v reader functionality between normal file and
#   secret file formats.
# 
kitbash.vars.files.read_into() {
  local fn key value
  local -n target
  log.debug "Received target '$2'"
  fn="$1"
  target="$2"
  
  [[ -e "$fn" && -f "$fn" ]] || {
    log.warn "Not a file: '$fn'"
    return 1
  }
  types.hash.exists "$2" || {
    log.error "Target $2 not declared."
    return "$?"
  }
  
  while read -r line || [[ -n "$line" ]]; do
    # Reset key and value.
    key=""
    val=""
    log.debug "Loaded line: '$line'"
    
    if __kitbash_parse_line "$line"; then
      log.debug "Line parsed"
      # If the key does not exist, then set it.
      # If it does exist, then we don't want to overwrite it.
      [[ ! -v target["$KITBASH_KV_PARSE_KEY"] ]] && {
        log.debug "Setting $KITBASH_KV_PARSE_KEY in target $2"
        target["${KITBASH_KV_PARSE_KEY}"]="$KITBASH_KV_PARSE_VAL"
      }
    else
      # Otherwise, we can just continue onwards.
      continue
    fi
  done < "$fn"
  log.debug "Finished reading $fn"
}

__kitbash_parse_line() {
  local line key value
  declare -g KITBASH_KV_PARSE_KEY
  declare -g KITBASH_KV_PARSE_VAL
  line="$1"
  
  log.debug "called with line: '$line'"
  
  # First, trim leading whitespace
  line="${line#"${line%%[![:space:]]*}"}"
  
  # Second, check if the first character is a comment
  # If we start with a comment, skip line.
  if [[ "${line::1}" == "#" ]]; then
    # Just return, since comments are skipped
    return
  fi
  
  # Trim trailing whitespace as well, just to normalise things up
  line="${line%"${line##*[![:space:]]}"}"
  
  # If there's nothing left, we can skip the line
  [[ -z "$line" ]] && return 0
  
  # We have three types of valid k=v styles:
  # foo=bar_baz
  # foo="bar baz"
  # foo='bar baz'
  # So, we want to regex test for all of them
  
  regex_key="[A-Za-z_][A-Za-z0-9_]*"
  
  regex_unquoted="^($regex_key)=([A-Za-z0-9_#%^*@\.]+)(\s#.*)*$"
  # regex_doublequoted="^([A-Za-z_][A-Za-z0-9_]*)=\"([^\"]*)\"$"
  regex_doublequoted='^([A-Za-z_][A-Za-z0-9_]*)="(([^"\\]|\\.)*)"$'
  regex_singlequoted="^([A-Za-z_][A-Za-z0-9_]*)='(([^'\\\\]|\\\\.)*)'$"
  
  if [[ "$line" =~ $regex_unquoted ]]; then
    log.debug "Found unquoted line $line"
    # Captures the possible comment at the end
    key="${BASH_REMATCH[1]}"
    val="${BASH_REMATCH[2]}"
  elif [[ "$line" =~ $regex_doublequoted || "$line" =~ $regex_singlequoted ]]; then
    # This implicitly drops trailing comments
    key="${BASH_REMATCH[1]}"
    val="${BASH_REMATCH[2]}"
    # Strip escapes
    val="${val//\\\"/\"}"
    val="${val//\\\'/\'}"
    val="${val//\\\\/\\}"
  else
    # If we didn't match any of our styles, we abort here.
    log.warn "Line did not match k=v parse rules"
    log.debug "${BASH_REMATCH[0]}"
    log.debug "$line"
    return 1
  fi
  
  # finally, assign to the globals for return to the caller.
  KITBASH_KV_PARSE_KEY="$key"
  KITBASH_KV_PARSE_VAL="$val"
}
