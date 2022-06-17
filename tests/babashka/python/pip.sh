test_pip_installed() {
  requires babashka.enable.pip
  system.package.pip pyaml
}

test_pip_uninstalled() {
  requires babashka.enable.pip
  system.package.pip.absent pyaml
}
