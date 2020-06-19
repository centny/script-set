#!/bin/bash
docker run --privileged -p 10022:22 -p 16060:6060 -v /sys/fs/cgroup:/sys/fs/cgroup --restart=always --name dev --hostname dev.loc -v /Users/vty:/home/vty/ -P -d dev /usr/sbin/init
