local ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "`uname -s`" in
  Linux)
    if [ -e /usr/bin/lsb_release ]; then
      # It's something that adheres to LSB!
      # However, this should make some more tests to see if it's new enough
      # that it's actually running systemd, since it might not be
      # and that's important to know.
      case "`lsb_release -is`" in
      Debian)
        ;&
      Ubuntu)
        __babashka_load_deps_from_path $ABSOLUTE_PATH/systemd
        ;;
      esac
    elif [ -e /etc/alpine-release ]; then
      # it's Alpine Linux! Also Woo!
      # Also this should get checked for whether or not it's running
      # openrc. I'm pretty sure all Alpine releases do? But who knows really.
      __babashka_load_deps_from_path $ABSOLUTE_PATH/openrc
    fi
    ;;
  # Darwin)
  #   # Probably macOS
  #   # TODO: Support launchctl here.
  #   ;;
esac