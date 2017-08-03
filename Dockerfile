FROM alpine:3.6

MAINTAINER derFunk <github@photono.de>

ARG AWSCLI_VERSION

RUN apk --no-cache --update add \
    python \
    py-pip \
    && pip install --upgrade pip 

RUN pip install awscli==${AWSCLI_VERSION} \
    && apk del py-pip 

