#!/bin/bash

if [ "$5" = "" ]
then
	echo "$0 [nim-debfile] [image name] [counter enabled (true|false)] [auth username] [auth password]"
	exit
fi

DEBFILE=$1
IMGNAME=$2
COUNTER=$3
USERNAME=$4
PASSWORD=$5

echo "==> Building NIM docker image"

docker build --no-cache --build-arg NIM_DEBFILE=$DEBFILE --build-arg BUILD_WITH_COUNTER=$COUNTER \
	--build-arg NIM_USERNAME=$USERNAME --build-arg NIM_PASSWORD=$PASSWORD -t $IMGNAME .
docker push $IMGNAME
