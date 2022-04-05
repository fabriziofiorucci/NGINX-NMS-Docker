FROM ubuntu:20.04
ARG NIM_DEBFILE
ARG BUILD_WITH_COUNTER=false

# Initial setup
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y -q build-essential git nano curl jq wget gawk lsb-release rsyslog systemd && \
	mkdir -p deployment/setup

# NGINX Instance Manager 2.0
COPY $NIM_DEBFILE /deployment/setup/nim.deb
COPY ./container/startNIM.sh /deployment/

WORKDIR /deployment/setup

RUN chmod +x /deployment/startNIM.sh && \
	wget https://docs.nginx.com/nginx-instance-manager/scripts/fetch-external-dependencies.sh -qO /deployment/setup/fetch-external-dependencies.sh

### Patch for bug in 2.1.0 RC
RUN cat /deployment/setup/fetch-external-dependencies.sh | sed "s/repo.clickhouse.tech/repo.clickhouse.com/g" > /deployment/setup/fetch-external-dependencies.sh.patched && \
	mv /deployment/setup/fetch-external-dependencies.sh.patched /deployment/setup/fetch-external-dependencies.sh
###

RUN bash /deployment/setup/fetch-external-dependencies.sh ubuntu20.04 && \
	tar -zxvf nms-dependencies-ubuntu20.04.tar.gz && \
	dpkg -i ./*.deb && \
	rm *.deb && \
	rm /etc/nginx/conf.d/default.conf

COPY $NIM_DEBFILE /deployment/setup/nim.deb

RUN apt-get -y install /deployment/setup/nim.deb && \
	curl -s http://hg.nginx.org/nginx.org/raw-file/tip/xml/en/security_advisories.xml > /usr/share/nms/cve.xml && \
	rm -r /deployment/setup

# Optional F5 Telemetry Tracker
WORKDIR /deployment
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then apt-get install -y python3-pip python3-dev python3-simplejson && \
	pip3 install fastapi uvicorn requests pandas xlsxwriter jinja2 && \
	touch /deployment/counter.enabled && \
	git clone https://github.com/fabriziofiorucci/F5-Telemetry-Tracker && \
	cp F5-Telemetry-Tracker/f5tt/app.py . && \
	cp F5-Telemetry-Tracker/f5tt/bigiq.py . && \
	cp F5-Telemetry-Tracker/f5tt/nim.py . && \
	cp F5-Telemetry-Tracker/f5tt/nms.py . && \
	cp F5-Telemetry-Tracker/f5tt/nc.py . && \
	cp F5-Telemetry-Tracker/f5tt/cveDB.py . && \
	rm -rf F5-Telemetry-Tracker; fi
	
WORKDIR /deployment
CMD /deployment/startNIM.sh
