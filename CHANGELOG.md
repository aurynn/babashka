# v0.0.3

- Adds additional search paths for dependencies
- Adds helpers
- `babashka` will now traverse symlinks for dependencies
- Add some helpers for more easily writing built-ins
- Add builtins for managing system files
- Add a Vagrant environment for initial testing
- Begin to define some initial test cases
- Documentation

# v0.0.2

- Rename `install_package` to `system.package` in `deps/package.sh`
- Create `deps/system.sh`, adding `system.user`, `system.group`, and `system.directory` functions
- Change to use `babashka/`, `babaskha/dependencies` and `/etc/babashka/dependencies` as source directories

# v0.0.1

- Initial release by @richo
