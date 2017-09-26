FROM awscli-versionized-base:latest

MAINTAINER derFunk <github@photono.de>

ARG AWSCLI_VERSION

RUN pip install awscli==${AWSCLI_VERSION} \
    && apk del py-pip 