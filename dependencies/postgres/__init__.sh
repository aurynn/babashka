local ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "`uname -s`" in
  Linux)
   # TODO: things other than Debian derivatives
   case "`lsb_release -is`" in
    Debian)
      ;&
    Ubuntu)
      __babashka_load_deps_from_path $ABSOLUTE_PATH/debian
      ;;
   esac
   ;;
esac

# TODO
# Add other systems here
