#!/bin/bash
docker run --privileged -v /sys/fs/cgroup:/sys/fs/cgroup --restart=always --name dev.loc --hostname dev.loc -P -d centos /usr/sbin/init