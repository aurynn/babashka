# Declare internal functions
declare -gA __babashka_system_info

__babashka_parse_etc_os_release() {
  local key
  local val
  
  while IFS='=' read -r key val; do
    # Skip empty lines or comments
    [[ -z "$key" || "$key" == \#* ]] && continue
    # Remove surrounding quotes (if any)
    val="${val%\"}"
    val="${val#\"}"
    # add to the associative array, so it's usable by the relevant helper
    #   functions
    __babashka_system_info["$key"]="$val"
  done < /etc/os-release
}

__babashka_parse_sw_vers() {
    local key
    local val
    
    while IFS=":" read -r key val; do
        case "$key" in
            ProductName)
                # Unlikely that they'll change it, but, you know, they might.
                # Should be "macOS".
                __babashka_system_info["NAME"]="$val"
                ;;
            ProductVersion)
                __babshka_system_info["VERSION_ID"]="$val"
                ;;
            *)
            # Just ignore the rest, really
            ;;
        esac
    done < <(sw_vers)
}

__babashka_get_macos_codename() {
  # pull product version out of sw_vers 
  local version="${1:-$(sw_vers -productVersion)}"
  local major
  local minor
  local _
  IFS='.' read -r major minor _ <<< "$version"
  
  # It's not like we'll ever use anything older than, say, Catalina for any
  #   of this, but it's helpful to have a mapping for all of it.
  case "$major.$minor" in
    10.0) echo "Cheetah" ;;
    10.1) echo "Puma" ;;
    10.2) echo "Jaguar" ;;
    10.3) echo "Panther" ;;
    10.4) echo "Tiger" ;;
    10.5) echo "Leopard" ;;
    10.6) echo "Snow Leopard" ;;
    10.7) echo "Lion" ;;
    10.8) echo "Mountain Lion" ;;
    10.9) echo "Mavericks" ;;
    10.10) echo "Yosemite" ;;
    10.11) echo "El Capitan" ;;
    10.12) echo "Sierra" ;;
    10.13) echo "High Sierra" ;;
    10.14) echo "Mojave" ;;
    10.15) echo "Catalina" ;;
    11*) echo "Big Sur" ;;
    12*) echo "Monterey" ;;
    13*) echo "Ventura" ;;
    14*) echo "Sonoma" ;;
    15*) echo "Sequoia" ;;
    # We don't know if the next version will actually be 26 or not yet.
    #   Guess we'll find out when Apple decides to tell us?
    16*|26*) echo "Tahoe" ;;
    # "Unknown" is a good default
    *) echo "Unknown" ;;
  esac
}

__babashka_macos_pretty_name() {
  local version="${1:-$(sw_vers -productVersion)}"
  local major
  local minor
  local _ 
  IFS='.' read -r major minor _ <<< "$version"
  
  local codename
  codename="$(__babashka_get_macos_codename "$version")"
  
  if [[ $codename == "Unknown" ]]; then
    echo "Unknown macOS"
  elif (( major == 10 )); then
    echo "Mac OS X $version $codename"
  else
    echo "macOS $major $codename"
  fi
}

__babashka_load_system_info() {
  ## TODO
  ##  - Support for other OS'es beyond Linux and macOS
  ##  - Disks and available space
  ##  - 
    case "$(uname -s)" in
        Linux)
            # parse /etc/os-release since we can be reasonably assured that
            #   it exists.
            __babashka_parse_etc_os_release
            __babashka_system_info["CPUS"]="$(lscpu -p | grep -E -v '^#' | sort -u -t, -k 2,4 | wc -l)"
            __babashka_system_info["LOGICAL_CPUS"]="$(nproc --all)"
            # Is this a stable value?
            __babashka_system_info["MEMORY"]="$(free -g | awk '/^Mem:/{print $2}')"
            # TODO
            #  - A way to get performance and efficiency core information into here.
            #      As I don't have a machine with a performance/efficiency core
            #      split that's running Linux, I can't test any means of doing this.
            __babashka_system_info["KERNEL"]="linux"
            
            local init
            if ! init="$(__kitbash_identify_init)"; then
              kitbash.fail "Could not identify init system"
            fi
            __babashka_system_info["INIT"]="$init"
        ;;
        Darwin)
            # so /etc/os-release does not exist on macOS, because, why would it.
            # Also, Apple switched from Mac OS X to macOS with 10.15 -> 11.
            
            __babashka_system_info["ID"]="macos"
            __babashka_system_info["KERNEL"]="darwin"
            __babashka_system_info["VERSION_CODENAME"]=__babashka_get_macos_codename
            __babashka_system_info["PRETTY_NAME"]=__babashka_macos_pretty_name
            __babashka_parse_sw_vers
            
            local tmp_memsize
            __babashka_system_info["CPUS"]="$(sysctl -n hw.physicalcpu)"
            __babashka_system_info["LOGICAL_CPUS"]="$(sysctl -n hw.logicalcpu)"
            __babashka_system_info["PERFORMANCE_CORES"]="$(sysctl -n hw.perflevel0.physicalcpu)"
            __babashka_system_info["EFFICIENCY_CORES"]="$(sysctl -n hw.perflevel1.physicalcpu)"
            local tmp_memsize
            tmp_memsize="$(sysctl -n hw.memsize)"
            __babashka_system_info["MEMORY"]=$((tmp_memsize / 1024 / 1024 ))
            __babashak_system_info["INIT"]="launchd"
            ;;
        *)
          echo "Unknown system"
          exit 1
            ;;
    esac
    __babashka_system_info["ARCH"]="$(uname -m)"
    __babashka_system_info["NODENAME"]="$(uname -n)"
}

__kitbash_identify_init() {
  # systemd: both systemctl AND the runtime dir must exist
  if command -v systemctl >/dev/null 2>&1 \
     && [[ -d /run/systemd/system ]]; then
    printf 'systemd\n'
    return 0
  fi
  
  # OpenRC: rc-status exists and "supervise-daemon" exists
  if command -v rc-status >/dev/null 2>&1 \
     && command -v supervise-daemon >/dev/null 2>&1; then
    printf 'openrc\n'
    return 0
  fi
  
  # SysV fallback: presence of /etc/init.d and 'service'
  if command -v service >/dev/null 2>&1 \
     && [[ -d /etc/init.d ]]; then
    printf 'sysv\n'
    return 0
  fi
  # Otherwise we don't know
  printf 'unknown\n'
  return 1
}

# Load system info
__babashka_load_system_info

#
#
# Provides some pleasant helper functions to make fetching certain system
#   information easier when writing configuration.
#
#

# what if: info.system
system.info() {
  local segment
  segment="$(normalize "$1")"
  # Generate the list of keys
  # local known_segments=("${!__babashka_system_info[@]}")
  
  # We have to define a segment to inspect
  [[ -n "$segment" ]] || return 2
  # If the segment isn't one we know to look for, abort
  # Skip the 2154 check, since __babashka_system_info is defined in
  #   bin/babashka, and this file is expected to be sourced by that.
  # TODO: Add some sort of exception if it's undefined?
  # shellcheck disable=SC2154
  in_array "$1" "${!__babashka_system_info[@]}" || return 4
  
  # Fetch and normalise what we have in our array
  local value
  value="$(normalize "${__babashka_system_info["$segment"]}")"
  
  echo "$value"
  return 0
}

##

system.info.test() {
  local segment
  local to_test
  segment="$(normalize "$1")"
  to_test="$(normalize "$2")"
  [[ -n "$segment" ]] || return 2
  [[ -n "$to_test" ]] || return 3
  local value
  local status
  value="$(system.info "$segment")"
  status=$?
  (( $status == 0 ))  || return $status
  [[ "$value" == "$to_test" ]]
}

##

system.info.like() { 
  system.info.test ID_LIKE "$1" || system.info.test ID "$1"
}

##

system.info.id() {
  system.info.test "ID" "$1"
}

##

system.info.name() {
  system.info.test "NAME" "$1"
}

##

system.info.version() {
  system.info.test "VERSION_ID" "$1"
}

##

system.info.arch() {
  system.info.test "ARCH" "$1"
}

##

system.info.nodename() {
  system.info.test "NODENAME" "$1"
}

##

system.info.cpus() {
  system.info.test "CPUS" "$1"
}

##

system.info.memory() {
  system.info.test "MEMORY" "$1"
}

system.info.init() {
  system.info.test INIT "$1"
}