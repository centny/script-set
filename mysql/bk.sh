#/bin/bash
set -e
cd `dirname ${0}`
ws_d=bk.ws
log_f=$ws_d/b.log
exe_f=$ws_d/ec
up_d=$ws_d/up
date_f=$ws_d/date

dfd=7		#do full backup time
usr=root	#the mysql user.
pwd=sco		#the mysql password.
dbs=bk		#the backup database name.
ftp_u=cny 	#the ftp server user name.
ftp_p=sco	#the ftp password.
ftp_h=localhost	#the ftp host.
binl=backu	#the backup log_bin name.

#do init
now=`date +%Y%m%d`
if [ ! -d $ws_d ];then
 mkdir $ws_d
fi
if [ ! -f $exe_f ];then
 echo 8 >$exe_f
fi
if [ ! -d $up_d ];then
 mkdir $up_d
fi
if [ ! -f $date_f ];then
 echo $now>$date_f
fi
####
cday=`cat $date_f`
if [ ! -d $cday ];then
 mkdir -p $up_d/$cday
fi
#
dobacku_d(){
 if [ $1 = "Y" ];then
  mysqladmin -u$usr -p$pwd flush-logs
 fi
 echo exe backup daily $now>>$log_f
 fs=(`ls $binl.*`)
 fs_l=${#fs[@]}
 fs_l=$(($fs_l-2))
 echo "uploading $fs_l file to server">>$log_f
 if [ $fs_l -lt 1 ];then
  return
 fi 
 for((i=0;i<$fs_l;i++))do
  f=${fs[$i]}
  curl -s -u $ftp_u:$ftp_p --ftp-create-dirs -T $f ftp://$ftp_h/$cday/
  mv $f $up_d/$cday/
 done
 curl -s -u $ftp_u:$ftp_p --ftp-create-dirs -T $binl.index ftp://$ftp_h/$cday/
 cp $binl.index $up_d/$cday/
 echo "daily backup success $now">>$log_f
}
dobacku_f(){
 echo "<<<<<<<<-------FULL------->>>>>>>>>">>$log_f
 echo "exec full backup $now">>$log_f
 mkdir -p $up_d/$now
 mysqldump -u$usr -p$pwd --opt --flush-logs $dbs> $up_d/$now/db.mdb
 dobacku_d Y
 curl -s -u $ftp_u:$ftp_p --ftp-create-dirs -T $up_d/$now/db.mdb ftp://$ftp_h/$now/
 echo $now>$date_f
 echo "full backup success $now">>$log_f
}

ecv=`cat $exe_f`
if [ $ecv -lt $dfd ];then
 dobacku_d N
 ecv=$(($ecv+1))
 echo $ecv>$exe_f
else
 dobacku_f
 echo 0 >$exe_f
fi
curl -s -u $ftp_u:$ftp_p --ftp-create-dirs -T $ws_d/b.log ftp://$ftp_h/
