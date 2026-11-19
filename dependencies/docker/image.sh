# docker.prerequisites.install() {
#   # Needed for managing Docker installations
#   requires docker.prerequisites.skopeo
#   system.package jq
# }

docker.image() {
  local image
  image="$1"
  shift

  __babashka_log "== ${FUNCNAME[0]} $image"
  # this needs to verify that Docker is, in fact, installed
  if ! [[ -e /usr/bin/docker ]] && ! [[ -x /usr/bin/docker ]]; then
    # Error out, because we don't have Docker installed
    __babashka_fail "Docker is not installed"
  fi
  # Don't bother resolving our pre-reqs until Docker is installed
  # requires docker.prerequisites.install
  function get_id() {
    echo "${image}"
  }
  function is_met() {
    emit i "Checking image existence"
    if ! docker inspect --format '{{.Id}}' "$image" > /dev/null 2>&1 ; then
      return 1
    fi
    emit info "Fetching local SHA"
    # LOCAL_SHA=$(/usr/bin/docker inspect --format '{{.Id}}' " 2> /dev/null)
    LOCAL_SHA=$(/usr/bin/docker inspect "$image" 2> /dev/null | jq -r '.[0].RepoDigests[-1]' | awk -F '@' '{print $2}')
    emit info "Fetching remote SHA"
    REMOTE_SHA=$(/usr/bin/skopeo inspect --format '{{.Digest}}' docker://"$image" 2> /dev/null)
    
    if [[ "$LOCAL_SHA" != "$REMOTE_SHA" ]]; then
      emit i "Local SHA is $LOCAL_SHA"
      emit i "Remote SHA is $REMOTE_SHA"
      return 1
    fi
    return 0
  }
  function meet() {
    # Apparently docker pull has decided to be noisy
    /usr/bin/docker pull -q "$image" > /dev/null 2>&1
  }
  process
}