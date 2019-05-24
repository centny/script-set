#!/bin/bash

installServer(){
  if [ ! -d /home/minici ];then
    useradd minici
    mkdir -p /home/minici
    chown -R minici:minici /home/minici
  fi
  cp -rf * /home/minici/srv/
  if [ ! -f /etc/systemd/system/minici.service ];then
    cp -f minici.service /etc/systemd/system/
  fi
  mkdir -p /etc/minici
  if [ ! -f /etc/minici/minici.json ];then
    cp -f minici.json /etc/minici/minici.json
  fi
  touch /etc/minici/minici.env
  systemctl enable minici.service
}

case "$1" in
  -i)
    installServer
    ;;
  *)
    echo "Usage: ./minici-install.sh -i"
    ;;
esac