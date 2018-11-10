#!/usr/bin/env bash

# alows you to combine 2 exe files one of payload and one inert and creates a dropper.py
# using pyinstaller -F we can create a single new exe file

apt update -y && apt upgrade -y
wget -o /root/Downloads/python-2.7.15.msi https://www.python.org/ftp/python/2.7.15/python-2.7.15.msi
dpkg --add-architecture i386 -y && apt update -y && apt install wine32 -y
wine msiexec /i /root/Downloads/python-2.7.15.msi
wine pip install pyinstaller
git clone https://github.com/d4rkcat/cryptbinder.git
cd cryptbinder
