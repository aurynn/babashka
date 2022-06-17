local ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "`uname -s`" in
  Linux)
   # TODO: things other than Debian derivatives
   case "`lsb_release -is`" in
    Debian)
      ;&
    Ubuntu)
      # TODO:
      # Find out if debian and ubuntu are the same here, dunno if they
      # are actually the same or not.
      # Oh well.
      __babashka_load_deps_from_path $ABSOLUTE_PATH/ubuntu
      ;;
   esac
   ;;
esac
