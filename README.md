A [babushka][1] like clone, written in bash.

## Installing

Clone this repo to the location of your choice, and add `babashka/bin` to your path.

```bash
git clone https://github.com/aurynn/babashka
echo "export PATH=$PWD/babashka/bin:\${PATH}" >>.bashrc
```

or, to install system-wide,

```bash
cd /opt
sudo git clone https://github.com/aurynn/babashka
sudo mkdir /etc/babashka
cd /etc/babashka
sudo ln -s /opt/babashka/dependencies .
sudo ln -s /opt/babashka/helpers .
sudo ln -s /opt/babashka/bin/babashka /usr/bin/babashka
```


## Organising dependencies

`babashka` looks for dependencies by searching the `./babashka/`, `./babashka/dependencies/` and `/etc/babashka/dependencies` folders for files ending in `.bash` or `.sh`.

Project-specific dependencies are conventionally kept in `./babashka/` and global dependencies are conventionally kept in `/etc/babashka/dependencies`.

For example, `~/projects/myapp/babashka/deploy.sh` might contain deployment scripts for an app called `myapp`, while `/etc/babashka/dependencies/packages.sh` might contain dependencies which install packages you commonly need on new systems.

## Custom dependency directories

`babashka` takes an argument, `-d`, to add another search path for dependencies.

## Templating

`babashka` comes with a built-in, `system.file.template`, which takes advantage of [Mo](https://github.com/tests-always-included/mo). This is an optional dependency.

## Writing dependencies

Write dependencies with a similar form to their babushka counterparts:

```bash

# dep zsh_installed
zsh_installed() {
  function is_met() {
    which zsh
  }
  function meet() {
    sudo aptitude install zsh
  }
  process # Process line is important, you must include it.
}

# dep mysql_environment
mysql_environment() {
  requires "mysql_server"
  requires "mysql_client"
  # Don't need process if this dep doesn't have meet or is_met
}

mysql_server() {
  function is_met() {
    which mysqld
  }
  function meet() {
    sudo aptitude install mysql-server
  }
  process
}

mysql_client() {
  function is_met() {
    which mysql
  }
  function meet() {
    sudo aptitude install mysql-client
  }
  process
}
```

## Running deps

Then invoke:

```bash

babashka zsh_installed
babashka mysql_environment
```

## What people are saying about babashka

"This is absolutely effing cursed"

~ [@ryankurte](https://twitter.com/ryankurte)

[1]: https://babushka.me
