FROM ubuntu:20.04
ARG NIM_DEBFILE
ARG BUILD_WITH_COUNTER=false

# Initial setup
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q build-essential git nano curl jq wget gawk lsb-release rsyslog systemd
RUN mkdir -p deployment/setup

# NGINX Instance Manager 2.0
COPY $NIM_DEBFILE /deployment/setup/nim.deb
COPY ./container/startNIM.sh /deployment/
RUN chmod +x /deployment/startNIM.sh
RUN wget https://docs.nginx.com/nginx-instance-manager/scripts/fetch-external-dependencies.sh -qO /deployment/setup/fetch-external-dependencies.sh

WORKDIR /deployment/setup
RUN bash /deployment/setup/fetch-external-dependencies.sh ubuntu20.04
RUN tar -zxvf nms-dependencies-ubuntu20.04.tar.gz
RUN dpkg -i ./*.deb
RUN rm *.deb
RUN rm /etc/nginx/conf.d/default.conf
COPY $NIM_DEBFILE /deployment/setup/nim.deb
RUN apt-get -y install /deployment/setup/nim.deb
RUN curl -s http://hg.nginx.org/nginx.org/raw-file/tip/xml/en/security_advisories.xml > /usr/share/nms/cve.xml
RUN rm -r /deployment/setup

# Optional NGINX Instance Counter
WORKDIR /deployment
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then apt-get install -y python3-pip python3-dev python3-simplejson; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then pip3 install fastapi uvicorn requests pandas xlsxwriter jinja2; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then touch /deployment/counter.enabled; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then git clone https://github.com/fabriziofiorucci/F5-Telemetry-Tracker; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp F5-Telemetry-Tracker/nginx-instance-counter/app.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp F5-Telemetry-Tracker/nginx-instance-counter/bigiq.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp F5-Telemetry-Tracker/nginx-instance-counter/nim.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp F5-Telemetry-Tracker/nginx-instance-counter/nms.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp F5-Telemetry-Tracker/nginx-instance-counter/nc.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp F5-Telemetry-Tracker/nginx-instance-counter/cveDB.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then rm -rf F5-Telemetry-Tracker; fi

WORKDIR /deployment
CMD /deployment/startNIM.sh
