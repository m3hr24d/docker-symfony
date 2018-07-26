FROM debian:stretch-slim

ARG PROJECT_NAME
ARG DEBUG=false
ARG APT_CACHER_SERVER

ENV PROJECT_USER=$PROJECT_NAME \
	PROJECT_GROUP=$PROJECT_NAME \
	PROJECT_PASSWORD=$PROJECT_NAME \
	PROJECT_NAME=$PROJECT_NAME \
	PROJECT_DIR='/srv/api' \
	DEBUG_MODE=$DEBUG \
	APT_CACHER_SERVER=$APT_CACHER_SERVER

RUN apt-get update && DEBCONF_FRONTEND=noninteractive apt-get install -y ca-certificates gnupg2 wget \
	apt-transport-https curl sudo git

RUN mkdir -p $PROJECT_DIR

ADD ./assets /tmp/$PROJECT_NAME/
RUN chmod 755 /tmp/$PROJECT_NAME/install.sh && /tmp/$PROJECT_NAME/install.sh

WORKDIR $PROJECT_DIR

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "--nodaemon"]