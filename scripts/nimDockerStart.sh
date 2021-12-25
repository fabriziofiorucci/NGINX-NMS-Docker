#!/bin/bash

NAMESPACE=nginx-nim2

case $1 in
	'start')
		kubectl create namespace $NAMESPACE

		pushd manifests/certs
		./cert-install.sh install
		cd ..

		kubectl apply -n $NAMESPACE -f .
		popd
	;;
	'stop')
		kubectl delete namespace $NAMESPACE
	;;
	*)
		echo "$0 [start|stop]"
		exit
	;;
esac
