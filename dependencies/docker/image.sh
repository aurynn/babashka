docker.prerequisites.install() {
  # Needed for managing Docker installations
  system.package skopeo
  system.package jq
}

docker.image() {
  local _image=$1; shift

  __babashka_log "${FUNCNAME[0]} $_image"
  # this needs to verify that Docker is, in fact, installed
  if ! [[ -e /usr/bin/docker ]] && ! [[ -x /usr/bin/docker ]]; then
    # Error out, because we don't have Docker installed
    __babashka_fail "Docker is not installed"
  fi
  # Don't bother resolving our pre-reqs until Docker is installed
  requires docker.prerequisites.install
  function is_met() {

    if ! $__babashka_sudo /usr/bin/docker inspect $_image 2>/dev/null | jq -e -r '.[0].Id'; then
      return 1
    fi
    LOCAL_SHA=$($__babashka_sudo /usr/bin/docker inspect $_image 2>/dev/null | jq -r '.[0].RepoDigests[0]' | cut -d '@' -f2)
    REMOTE_SHA=$(/usr/bin/skopeo inspect docker://$_image | jq -r '.Digest')

    if [[ $LOCAL_SHA != $REMOTE_SHA ]]; then
      return 1
    fi
    return 0
  }
  function meet() {
    $__babashka_sudo /usr/bin/docker pull -q $_image
  }
  process
}
