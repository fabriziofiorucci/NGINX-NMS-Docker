#!/bin/bash

if [ $# -lt 3 ]
then
        echo "$0 [nim-debfile] [NIM image name] [Second Sight enabled (true|false)] [optional: ACM .deb filename]"
        exit
fi

DEBFILE=$1
IMGNAME=$2
COUNTER=$3

if [ $# = 4 ]
then
	ACM_IMAGE=$4
else
	ACM_IMAGE=nim-files/.placeholder
fi

echo "==> Building NIM docker image"

docker build --no-cache --build-arg NIM_DEBFILE=$DEBFILE --build-arg BUILD_WITH_SECONDSIGHT=$COUNTER --build-arg ACM_IMAGE=$ACM_IMAGE -t $IMGNAME .
docker push $IMGNAME
