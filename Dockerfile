FROM alpine:latest

RUN apk update  \
  && apk add curl jq

ADD assets /opt/resource
RUN chmod +x /opt/resource/*
