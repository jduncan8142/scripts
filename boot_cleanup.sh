#!/usr/bin/env bash

dpkg -l linux-{image,headers}-"[0-9]*" | awk '/^ii/{ print $2}' | grep -v -e `uname -r | cut -f1,2 -d"-"` | grep -e '[0-9]' | xargs apt-get -y purge
apt-get -f install
apt-get autoremove
apt-get update
apt-get upgrade -y
