FROM ubuntu:20.04
ARG NIM_DEBFILE
ARG BUILD_WITH_COUNTER=false
ARG NIM_USERNAME
ARG NIM_PASSWORD

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q build-essential git nano curl jq wget gawk lsb-release rsyslog systemd
RUN mkdir -p deployment/setup

COPY $NIM_DEBFILE /deployment/setup/nim.deb
COPY ./container/startNIM.sh /deployment/startNIM.sh.tmp
RUN cat /deployment/startNIM.sh.tmp | sed 's/__NIM_USERNAME__/'$NIM_USERNAME'/g' | sed 's/__NIM_PASSWORD__/'$NIM_PASSWORD'/g' > /deployment/startNIM.sh
RUN rm /deployment/startNIM.sh.tmp
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
RUN bash /etc/nms/scripts/basic_passwords.sh $NIM_USERNAME $NIM_PASSWORD
RUN curl -s http://hg.nginx.org/nginx.org/raw-file/tip/xml/en/security_advisories.xml > /usr/share/nms/cve.xml
RUN rm -r /deployment/setup

WORKDIR /deployment
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then apt-get install -y python3-pip python3-dev python3-simplejson; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then pip3 install fastapi uvicorn requests pandas xlsxwriter jinja2; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then touch /deployment/counter.enabled; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then git clone https://github.com/fabriziofiorucci/NGINX-InstanceCounter; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp NGINX-InstanceCounter/nginx-instance-counter/app.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp NGINX-InstanceCounter/nginx-instance-counter/bigiq.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp NGINX-InstanceCounter/nginx-instance-counter/nim.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp NGINX-InstanceCounter/nginx-instance-counter/nms.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp NGINX-InstanceCounter/nginx-instance-counter/nc.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp NGINX-InstanceCounter/nginx-instance-counter/cveDB.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then rm -rf NGINX-InstanceCounter; fi

WORKDIR /data
CMD /deployment/startNIM.sh
