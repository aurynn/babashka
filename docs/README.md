## Babashka

Babashka is configuration management system written in Bash, designed to run with the barest minimum of installed packages.
It comes with some basic helper functions, as well as a suite of pre-written dependencies, to ensure that using Babashka for system management is consistent and idempotent.

### Helpers

```shell
user.get_gid username
```

Returns the GID of the username.

```shell
group.get_gid groupname
```

Returns the GID of the group name.

```shell
path.has_uid /path uid
```

Returns true if the path matches the UID given.

```shell
path.has_gid /path gid
```

Returns true if the path matches the GID given.

```shell
path.has_mode /path mode
```

Returns true of the path has the given mode.


### Built-ins

Babashka comes with a wide selection of built-in functionality.

#### System

##### System

```bash
system.group group_name \
  -g gid    # GID (optional)
```
Creates the group name with optional `gid`

```bash
system.user user_name \
  -g gid \              # GID (optional)
  -u uid \              # UID (optional)
  -h /path/to/homedir \ # Home directory
  -l /path/to/shell   \ # Shell to use
  -s is_system        \ # is a system account
```

Creates or modifies a user with the above settings.

```bash
system.package package_name
```

Installs the named package. Tries to autodetect the correct package manager for the system being used.

###### Ubuntu-specific

```shell
system.ubuntu.repository.official repository_name
```

Enables a specific, official Ubuntu repository, if needed.



##### Files

```shell
system.file file_name \
  -g group \        # group
  -o owner \        # owner
  -m mode \         # file mode
  -s /source/path \ # path to source
  -c "contents"     # literal contents.
```

Creates a file at the `file_name`, with either source or contents. Contents are mutually exclusive with a source file.

```shell
system.file.absent file_name
```

Removes the file at `file_name`, if present.

```shell
system.file.template file_name \
  -g group \              # Group
  -o owner \              # Owner
  -m mode \               # file mode
  -s /path/to/variables \ # path to template variables
  -t /path/to/template    # Path to template file
```

Creates a file at `file_name`, using the `mo` templating tool. Assumes that `mo` has been installed on the system.

```shell
system.file.symlink /source/path /dest/path 
```

Creates a symlink between source and destination.

##### Directories

```

```
