#!/bin/bash

containerLabel=""

if [ "$containerLabel" == "" ];then
    containerLabel=$1
fi

echo "start checking docker install"
dockerVer=$(docker -v)
if [ "$?" != "0" ];then
    echo '====<RESULT>==='
    echo 'status=NoSetup'
	echo 'message=docker is not found'
    exit 0
fi
printf "check docker install done, using $dockerVer\n\n\n"

dockerInfo=$(docker info)
if [ "$?" != "0" ];then
    echo "check docker if running fail with "
    echo $dockerInfo
    echo "try start docker"
    systemctl start docker
    if [ "$?" != "0" ];then
        echo '====<RESULT>==='
        echo 'status=ERROR'
        echo 'message=docker start fail'
        exit 0
    fi
    echo "docker start success"
fi
echo "check docker info done, info is"
printf "$dockerInfo\n\n\n"

containerID=$(docker ps -aqf "label=$containerLabel")
if [ "$?" != "0" ];then
    echo 'docker ps container fail with '
    echo $containerID
    echo '====<RESULT>==='
    echo 'status=ERROR'
	echo 'message=docker ps container fail'
    exit 0
fi
echo "list container is done, id is"
printf "$containerID\n\n\n"

if [ "$containerID" == "" ];then
    echo '====<RESULT>==='
    echo 'status=NoSetup'
    echo 'message=container is not found'
    exit 0
fi
containerCount=$(echo $containerID | wc -l)
if [ "$containerCount" != "1" ];then
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'message=found '+$containerCount+' container'
    exit 0
fi

containerImage=$(docker inspect --format '{{.Image}}' $containerID)
containerStatus=$(docker inspect --format '{{.State.Status}}' $containerID)
if [ "$containerStatus" != "running" ];then
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'message=container is not running'
    echo 'container_image='$containerImage
    echo 'container_status='$containerStatus
    exit 0
fi
containerHealth=$(docker inspect --format '{{.State.Health.Status}}' $containerID)
if [ "$?" != "0" ];then
    echo 'docker inspect health fail with '
    echo $containerHealth
    echo '====<RESULT>==='
    echo 'status=ERROR'
    echo 'message=check container health fail'
    echo 'container_image='$containerImage
    echo 'container_status='$containerStatus
    exit 0
fi
echo 'check all is done'
echo '====<RESULT>==='
echo 'status=OK'
echo 'message=all is done'
echo 'container_image='$containerImage
echo 'container_status='$containerStatus
echo 'container_health='$containerHealth
