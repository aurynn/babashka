local ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "`uname -s`" in
  Linux)
    if [ -e /usr/bin/lsb_release ]; then
      # It's something that adheres to LSB!
      # TODO: things other than Debian derivatives
      case "`lsb_release -is`" in
      Debian)
        ;&
      Ubuntu)
        __babashka_load_deps_from_path $ABSOLUTE_PATH/apt
        ;;
      esac
    elif [ -e /etc/arch-release ]; then
      # it's Arch Linux! Woo!
      __babashka_load_deps_from_path $ABSOLUTE_PATH/pacman
    elif [ -e /etc/alpine-release ]; then
        # it's Alpine Linux! Also Woo!
        __babashka_load_deps_from_path $ABSOLUTE_PATH/apk
    fi
    ;;
  Darwin)
    # Probably macOS
    # Probably _probably_ Homebrew
    __babashka_load_deps_from_path $ABSOLUTE_PATH/brew
    ;;
esac