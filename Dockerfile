FROM debian:8

RUN apt-get -y update \
  && apt-get -y install curl jq

ADD assets /opt/resource
RUN chmod +x /opt/resource/*
