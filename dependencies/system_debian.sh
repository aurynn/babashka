# __diff_remote_key() {
#
# }

function __system.debian.repo.custom.worker() {
  system.file ${_gpg_key_path} \
    -o root \
    -g root \
    -m 0644 \
    -s ${_keyfile}
  # I'm not sure this is a good idea...
  # The signed-by, specifically
  system.file ${_repo_path} \
    -o root \
    -g root \
    -m 0644 \
    -c "deb [arch=${arch} signed-by=${_gpg_key_path}] ${url} ${distribution} ${channel}"
}

function system.debian.repo.custom() {
  local _repo_name=$1; shift

  while getopts "k:u:a:c:d:" opt; do
    case "$opt" in
      k)
        # Key URL or file
        local key=$(echo $OPTARG | xargs);;
      u)
        # URL of the repo
        local url=$(echo $OPTARG | xargs);;
      a)
        # arch
        local arch=$(echo $OPTARG | xargs);;
      c)
        local channel=$(echo $OPTARG | xargs);;
      d)
        # override the distribution name
        local distribution=$(echo $OPTARG | xargs);;
    esac
  done
  # Reset our loops, to not break other things
  unset OPTIND
  unset OPTARG
  __funcname=${FUNCNAME[0]}
  __babashka_log "${FUNCNAME[0]} $_repo_name"
  _gpg_key_path=/usr/share/keyrings/${_repo_name}-archive-keyring.gpg
  _repo_path=/etc/apt/sources.list.d/${_repo_name}.list

  function is_met() {
    # and the apt repo on-disk is up-to-date? Hmm.
    if [[ "$distribution " == " " ]]; then
      distribution=$(lsb_release -cs)
    fi
    __babashka_log "key path: $_gpg_key_path"
    __babashka_log "repo path: $_repo_path"
    if [[ -e $_gpg_key_path ]] && \
      [[ -e $_repo_path ]]; then
      return 0;
    fi
    # __babashka_log $?
    return 1
  }
  function meet() {
    if [[ "$distribution " == " " ]]; then
      distribution=$(lsb_release -cs)
    fi
    if echo $key | grep -q "http[s]*://"; then
      /usr/bin/curl -fsSL $key | $__babashka_sudo gpg --dearmor --yes -o $HOME/${_repo_name}-archive-keyring.gpg
      _keyfile=$HOME/${_repo_name}-archive-keyring.gpg
    else
      _keyfile=$key
    fi

    __babashka_log "${__funcname}: creating GPG key"

    # requires_nested to force Babashka to call out to a new script context
    # and run this, before coming back and finishing up here.
    # Should(??) work.

    # wait how did the variables make it into the function call
    # weeeeird
    requires_nested __system.debian.repo.custom.worker

    __babashka_log "${__funcname}: running apt update"
    DEBIAN_FRONTEND=noninteractive $__babashka_sudo apt-get -yqq update
    return 0
  }
  process
}
