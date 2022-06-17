function babashka.enable.pip() {
  case `lsb_release -cs` in
    "bionic")
      system.package python
      system.package python-pip
      ;;
    "focal")
      ;&
    "jammy")
      system.package python3-pip
      system.package python-is-python3
      ;;
  esac
}
