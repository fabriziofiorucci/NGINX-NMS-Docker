#!/bin/bash

if [ -f "/deployment/counter.enabled" ]
then
	export NGINX_CONTROLLER_TYPE=NGINX_MANAGEMENT_SYSTEM
	export NGINX_CONTROLLER_FQDN="https://127.0.0.1:443"
	export NGINX_CONTROLLER_USERNAME=$NIM_USERNAME
	export NGINX_CONTROLLER_PASSWORD=$NIM_PASSWORD

	python3 /deployment/app.py &
fi

/etc/nms/scripts/basic_passwords.sh $NIM_USERNAME $NIM_PASSWORD

/etc/init.d/clickhouse-server start
/etc/init.d/nginx start

# Start nms core - from /lib/systemd/system/nms-core.service
/bin/bash -c '`which mkdir` -p /var/lib/nms/dqlite/'
/bin/bash -c '`which mkdir` -p /var/lib/nms/secrets/'
/bin/bash -c '`which mkdir` -p /var/run/nms/'
/bin/bash -c '`which chown` -R nms:nms /var/log/nms/'
/bin/bash -c '`which chown` -R nms:nms /var/lib/nms/'
/bin/bash -c '`which chown` -R nms:nms /var/run/nms/'
/bin/bash -c '`which chown` -R nms:nms /etc/nms/certs/services/core'
/bin/bash -c '`which chown` nms:nms /etc/nms/certs/services/ca.crt'
/bin/bash -c '`which chmod` 0700 /etc/nms/certs/services/core'
/bin/bash -c '`which chmod` 0600 /etc/nms/certs/services/core/*'
/usr/bin/nms-core &

# Start nms dpm - from /lib/systemd/system/nms-dpm.service
/bin/bash -c '`which mkdir` -p /var/lib/nms/streaming/'
/bin/bash -c '`which mkdir` -p /var/lib/nms/dqlite/'
/bin/bash -c '`which mkdir` -p /var/run/nms/'
/bin/bash -c '`which chown` -R nms:nms /var/log/nms/'
/bin/bash -c '`which chown` -R nms:nms /var/lib/nms/'
/bin/bash -c '`which chown` -R nms:nms /var/run/nms/'
/bin/bash -c '`which chown` -R nms:nms /etc/nms/certs/services/dataplane-manager'
/bin/bash -c '`which chown` nms:nms /etc/nms/certs/services/ca.crt'
/bin/bash -c '`which chmod` 0700 /etc/nms/certs/services/dataplane-manager'
/bin/bash -c '`which chmod` 0600 /etc/nms/certs/services/dataplane-manager/*'
/usr/bin/nms-dpm &

# Start nms ingestion - from /lib/systemd/system/nms-ingestion.service
/bin/bash -c '`which mkdir` -p /var/run/nms/'
/bin/bash -c '`which chown` -R nms:nms /var/log/nms/'
/bin/bash -c '`which chown` -R nms:nms /var/run/nms/'
/usr/bin/nms-ingestion &

sleep 5

chmod 666 /var/run/nms/*.sock

while [ 1 ]
do
	sleep 60
done
