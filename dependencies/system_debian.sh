function system.debian.repo.custom() {
  _repo_name=$1; shift

  while getopts "k:u:a:c:" opt; do
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
    esac
  done
  # Reset our loops, to not break other things
  unset OPTIND
  unset OPTARG

  __babashka_log "${FUNCNAME[0]} $_repo_name"
  _gpg_key_path=/usr/share/keyrings/${_repo_name}-archive-keyring.gpg
  _repo_path=/etc/apt/sources.list.d/${_repo_name}.list

  function is_met() {
    # and the apt repo on-disk is up-to-date? Hmm.
    [[ -e $_gpg_key_path ]] && \
      [[ -e $_repo_path ]]
  }
  function meet() {
    local lsb_release=$(lsb_release -cs)

    if echo $key | grep -q "http[s]*://"; then
      /usr/bin/curl -fsSL $key | $__babashka_sudo gpg --dearmor --yes -o /root/${_repo_name}-archive-keyring.gpg
      _keyfile=/root/${_repo_name}-archive-keyring.gpg
    else
      _keyfile=$key
    fi

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
      -c "deb [arch=${arch} signed-by=${_gpg_key_path}] ${url} ${lsb_release} ${channel}"

    __babashka_log "${FUNCNAME[0]}: running apt update"
    DEBIAN_FRONTEND=noninteractive $__babashka_sudo apt-get -yqq update
  }
  process
}
