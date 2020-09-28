#!/bin/bash
containerImage="docker.dev.gdy.io/xkz:v1.0.0"
containerLabel="abc"
containerName="abc"
containerArgs="-p 1841:1841 -p 2010:2010 -p 1973:1973 -p 1971:1971 -p 6372:6372 -v /data/abc:/data -e XKZ_COMMON_MAIN_HOST=172.18.1.102"
clearInstall="0"
dataID=$'abc'
accessID=$'localdev'
workingDir=$'/data/'
baseURI=$'http://127.0.0.1:5010/web/data'
dbHost=$'172.18.1.107'
dbPort=$'27017'
dbAdminUser=$'admin'
dbAdminPass=$'123'
dbAddName=$'abc'
dbAddUser=$'abc'
dbAddPass=$'123'

cd $workingDir
checksumFile=$dataID.tar.gz.sha1
dataFile=$dataID.tar.gz
dataOK="no"
if [ -f "$checksumFile" ] && [ -f "$dataFile" ];then
    echo "$dataFile is found, verify it"
    sha1sum -c $checksumFile
    if [ "$?" != "0" ];then
        echo 'checksum verify fail, remove it '
        rm -f $checksumFile $dataFile
    else 
        echo 'checksum verify is ok '
        dataOK="yes"
    fi
fi

if [ "$dataOK" != "yes" ];then
    echo "download checksum file from $baseURI/$dataID.tar.gz.sha1?access_id=$accessID"
    wget "$baseURI/$dataID.tar.gz.sha1?access_id=$accessID" -O $checksumFile
    if [ "$?" != "0" ];then
        echo 'download checksum file fail '
        echo '====<RESULT>==='
        echo 'status=ERROR'
        echo 'message=download checksum file fail'
        exit 0
    fi
    echo "download data file from $baseURI/$dataID.tar.gz?access_id=$accessID"
    wget "$baseURI/$dataID.tar.gz?access_id=$accessID" -O $dataFile
    if [ "$?" != "0" ];then
        echo 'download data file fail '
        echo '====<RESULT>==='
        echo 'status=ERROR'
        echo 'message=download data file fail'
        exit 0
    fi
    sha1sum -c $checksumFile
    if [ "$?" != "0" ];then
        echo 'verify data file fail '
        echo '====<RESULT>==='
        echo 'status=ERROR'
        echo 'message=verify data file fail'
        exit 0
    else 
        echo 'checksum verify is ok '
        dataOK="yes"
    fi
fi

echo "extracting $dataFile"
rm -rf $accessID
tar zxvf $dataFile
if [ "$?" != "0" ];then
    echo 'extracting fail'
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'message=extracting fail'
    exit 0
fi
if [ ! -d "$dataID" ];then
    echo 'extracting fail with folder not exists'
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'message=extracting fail with folder not exists'
    exit 0
fi
dbAdminURI="mongodb://$dbAdminUser:$dbAdminPass@$dbHost:$dbPort/admin"
echo "start add user to $dbAdminURI"
mongo "$dbAdminURI" << EOF
use abc;
db.getUser("$dbAddUser") || db.createUser({user: "$dbAddUser",pwd: "$dbAddPass",roles: [ "readWrite", "dbAdmin" ]});
EOF
if [ "$?" != "0" ];then
    echo 'mongo add user fail with '
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'message=mongo add user fail'
    exit 0
fi

dbUserURI="mongodb://$dbAddUser:$dbAddPass@$dbHost:$dbPort/$dbAddName"
echo "start restore data to $dbUserURI"
mongorestore -h $dbHost -p $dbPort -d $dbAddName --drop --dir $dataID/db/
if [ "$?" != "0" ];then
    echo 'mongo restore fail with '
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'message=mongo restore fail'
    exit 0
fi

containerID=$(docker ps -aqf "label=$containerLabel")
if [ "$?" != "0" ];then
    echo 'docker ps container fail with '
    echo $containerID
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'message=docker ps container fail'
    exit 0
fi

if [ "$clearInstall" == "1" ] && [ "$containerID" != "" ];then
    echo "start stop container $containerID"
    docker stop $containerID
    if [ "$?" != "0" ];then
        echo '====<RESULT>==='
        echo 'status=ERROR'
        echo 'message=docker stop container fail'
        exit 0
    fi
    echo "start remove container $containerID"
    docker rm $containerID
    if [ "$?" != "0" ];then
        echo '====<RESULT>==='
        echo 'status=ERROR'
        echo 'message=docker remove container fail'
        exit 0
    fi
    containerID=""
fi


if [ "$containerID" != "" ];then
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'message=container is setuped'
    exit 0
fi

echo "start pull image from $containerImage"
docker pull $containerImage
if [ "$?" != "0" ];then
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'message=docker pull image'
    exit 0
fi

echo "start run container by $containerImage"
docker run --privileged --label $containerLabel -d  $containerArgs $containerImage
if [ "$?" != "0" ];then
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'message=docker pull image'
    exit 0
fi

containerID=$(docker ps -aqf "label=$containerLabel")
if [ "$?" != "0" ];then
    echo 'docker ps container fail with '
    echo $containerID
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'message=docker ps container fail'
    exit 0
fi

if [ "$containerID" == "" ];then
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'messag=run container fail'
    exit 0
fi

echo 'setup all is done'
echo '====<RESULT>==='
echo 'status=OK'
echo 'message=all is done'
echo 'container_id='$containerID