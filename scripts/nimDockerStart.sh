#!/bin/bash

#CFGFILE=nim-files/nginx-manager.conf
#LICFILE=nim-files/nginx-manager.lic
MANIFEST=manifests/0.nginx-nim.yaml
NAMESPACE=nginx-nim2

case $1 in
	'start')
		kubectl create namespace $NAMESPACE

		cd manifests/certs
		./cert-install.sh install
		cd ../..

		kubectl apply -f $MANIFEST -n $NAMESPACE
	;;
	'stop')
		kubectl delete namespace $NAMESPACE
	;;
	*)
		echo "$0 [start|stop]"
		exit
	;;
esac
