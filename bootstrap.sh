#!/bin/bash

if [[ -d /opt/babashka ]]; then
  pushd /opt/babashka
  sudo git pull
  popd
else
  sudo git clone https://github.com/aurynn/babashka /opt/babashka
fi
[[ -e /usr/bin/babashka ]] || \
  sudo ln -s /opt/babashka/bin/babashka /usr/bin/babashka
[[ -d /etc/babashka ]] || \
  sudo mkdir -p /etc/babashka
[[ -L /etc/babashka/dependencies ]] || \
  sudo ln -s /opt/babashka/dependencies /etc/babashka/dependencies
[[ -L /etc/babashka/helpers ]] || \
  sudo ln -s /opt/babashka/helpers /etc/babashka/helpers
if [[ -d /opt/mo ]]; then
  pushd /opt/mo
  sudo git pull
  popd
else
  sudo git clone https://github.com/tests-always-included/mo.git /opt/mo
fi
if ! [[ -e /usr/bin/mo ]]; then
  sudo ln -s /opt/mo/mo /usr/bin/mo
fi
