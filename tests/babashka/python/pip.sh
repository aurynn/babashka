test_pip_installed() {
  requires babashka.enable.pip
  system.package.pip pyaml
}

test_pip_uninstalled() {
  requires babashka.enable.pip
  system.package.pip.absent pyaml
}

test_pip_installed_git() {
  requires babashka.enable.pip
  system.package.pip swiftbackmeup \
    -s "git+https://github.com/aurynn/swiftbackmeup.git@master"
}
