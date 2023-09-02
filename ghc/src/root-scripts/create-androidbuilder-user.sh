#!/bin/bash

PASSWORD=adb
USER=androidbuilder
HOME=/home/$USER
INSTALL="install -o $USER -g $USER"

deluser "$USER" --remove-home 2>/dev/null
rm -rf "$HOME"
cat <<EOF | useradd $USER --comment $USER --create-home 2>&1
$PASSWORD
$PASSWORD
EOF
