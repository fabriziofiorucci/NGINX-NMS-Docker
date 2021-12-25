#!/bin/bash

if [ "$3" = "" ]
then
	echo "$0 [nim-debfile] [image name] [counter enabled (true|false)]"
	exit
fi

DEBFILE=$1
IMGNAME=$2
COUNTER=$3

echo "==> Building NIM docker image"

docker build --no-cache --build-arg NIM_DEBFILE=$DEBFILE --build-arg BUILD_WITH_COUNTER=$COUNTER -t $IMGNAME .
docker push $IMGNAME
