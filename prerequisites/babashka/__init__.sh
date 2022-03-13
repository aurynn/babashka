
# Figure out exactly where we are in this file
local ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Load all the Docker dependencies
# TODO: Make this generic, and load all the subdirs
__babashka_load_deps_from_path $ABSOLUTE_PATH/docker
