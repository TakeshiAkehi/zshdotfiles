#!/bin/bash

if type "yazi" >/dev/null 2>&1; then
  echo "skipped : yazi has already installed"
else
  echo "installing yazi"
  if type "brew" >/dev/null 2>&1; then
    brew install yazi
  elif type "apt-get" >/dev/null 2>&1; then
    if [[ $(id -u) -ne 0 ]]; then
      SUDO="sudo"
    else
      SUDO=""
    fi
    curl -fsSL https://yazi-rs.github.io/builds/yazi-keyring.gpg | ${SUDO} tee /usr/share/keyrings/yazi-keyring.gpg >/dev/null
    echo 'deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main' | ${SUDO} tee /etc/apt/sources.list.d/yazi.list >/dev/null
    ${SUDO} apt-get update
    ${SUDO} apt-get install -y yazi
  else
    echo "no supported package manager found"
    exit
  fi
fi
