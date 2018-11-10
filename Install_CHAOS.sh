#!/usr/bin/env bash

apt update -y
apt upgrade -y
apt install goland upx-ucl -y
cd ~
git clone https://github.comtiagorlampert/CHAOS.git
cd CHAOS

# go run CHAOS.go
