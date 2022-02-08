# # Pulls a file from HTTP
# # This is extremely naive atm, since it's just assuming that the file already
# # existing is enough
# system.file.http() {
#   local _file_name=$1; shift
#   while getopts "g:o:m:u:" opt; do
#     case "$opt" in
#       g)
#         local group=$(echo $OPTARG | xargs);;
#       o)
#         local owner=$(echo $OPTARG | xargs);;
#       m)
#         local mode=$(echo $OPTARG | xargs);;
#       u)
#         local _source=$(echo $OPTARG | xargs);;
#     esac
#   done
#   unset OPTIND
#   unset OPTARG
#   __babashka_log "${FUNCNAME[0]} $_file_name"
#
#   # I think this needs to have a local download cache ... thing ... ?
#   # where files get downloaded so they can be compared to remote files
#   # or something idk
#   # it'd be nice to be able to support HTTP HEAD or whatever and check for
#   # file changes, but I don't think that actually exists broadly enough to
#   # be a guaranteed capability?
#   # so
#   # ... idk, I don't really want to download the file every time just to
#   # check if it's the same or not, especially if it's large
#
#   if [[ "$_source " == " " ]]; then
#     __babashka_fail "ERROR: ${FUNCNAME[0]} $_file_name -u must be provided"
#   fi
#
#   function is_met() {
#     # does the local path exist? if so, we're met
#     # TODO: Do some refresh logic I guess? That'd be nice?
#     ![[ -e $_file_name ]] && return 1
#   }
#   function meet() {
#     # Don't bother trying to refresh it
#     $__babashka_sudo /usr/bin/curl -fsSL $ -o $_file_name
#   }
#   process
#   requires
# }
