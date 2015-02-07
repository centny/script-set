mysql incremental backup script
======

##### install
do follow step

* configure mysql log_bin,add below to `my.conf`

```
log_bin=backu.log		#log_bin name,map to scipt configure "binl"
binlog-do-db=bk			#target backup db
binlog_format=MIXED
```

* copy `bk.sh` to `/var/lib/mysql` and edit the configure in `bk.sh`

```
dfd=7           #do full backup time
usr=root        #the mysql user.
pwd=            #the mysql password.
dbs=bk          #the backup database name.
ftp_u=cny       #the ftp server user name.
ftp_p=          #the ftp password.
ftp_h=localhost #the ftp host.
binl=backu      #the backup log_bin name.
```

* install crontab

```
yum install crontabs
chkconfig crond on
service crond start
```

* adding bk.sh to crontab
  * run `crontab -e` 
  * adding `* 10 1 * * /var/lib/mysql/bk.sh`



