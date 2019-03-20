#!/bin/bash
case "$1" in
  -i)
    if [ ! -d /home/cert ];then
      useradd cert
      mkdir -p /home/cert
      chown -R cert:cert /home/cert
    fi
    if [ ! -f /etc/systemd/system/gitlab-cert-srv.service ];then
      cp gitlab-cert-srv.service /etc/systemd/system/
    fi
    mkdir -p /home/cert/gitlab-cert-srv
    cp -rf * /home/cert/gitlab-cert-srv/
    chown -R cert:cert /home/cert/gitlab-cert-srv/
    systemctl enable gitlab-cert-srv.service
    ;;
  *)
    echo "Usage: ./cert-srv-install.sh -i"
    ;;
esac