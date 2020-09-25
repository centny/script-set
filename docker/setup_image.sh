#!/bin/bash
containerImage=""
containerLabel=""
containerName=""
containerArgs=""
clearInstall="0"

if [ "$containerImage" == "" ];then
    containerImage=$1
    containerLabel=$2
    if [ "$3" == "" ];then
        containerName=$containerLabel
    else
        containerName=$3
    fi
    if [ "$4" != "" ];then
        clearInstall="$4"
    fi
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