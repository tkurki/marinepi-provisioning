FROM alpine:3.11

ENV ANSIBLE_VERSION 2.9

RUN apk --update add bash python openssh py-pip openssl ca-certificates && \
    apk --update add --virtual build-dependencies python-dev libffi-dev openssl-dev build-base && \
    pip install --upgrade pip cffi

RUN pip install ansible==${ANSIBLE_VERSION}

RUN apk del build-dependencies && \
    rm -rf /var/cache/apk/*

WORKDIR /ansible
