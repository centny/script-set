docker run --privileged -v /sys/fs/cgroup:/sys/fs/cgroup -v C:/:/mnt/c -v D:/:/mnt/d --restart=always --name u.loc  --net work --ip 172.18.1.10 --hostname=u.loc -d centos /usr/sbin/init