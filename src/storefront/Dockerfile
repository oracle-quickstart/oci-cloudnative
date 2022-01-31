#
# Copyright (c) 2019-2022 Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0
#
ARG version

###############################
#    Build stage (node/npm)   #
###############################
FROM --platform=${BUILDPLATFORM:-linux/amd64} node:16-alpine as builder

RUN apk update && apk add --no-cache \
    autoconf \
    automake \
    bash \
    g++ \
    libtool \
    libc6-compat \
    libjpeg-turbo-dev \
    libpng-dev \
    make \
    nasm

RUN npm config set loglevel warn \
  && npm set progress=false

# install dependencies
COPY package.json /tmp/package.json
COPY package-lock.json /tmp/package-lock.json
RUN cd /tmp && npm ci
RUN mkdir -p /usr/src/app && cp -a /tmp/node_modules /usr/src/app/
RUN rm -rf /tmp/node_modules

# copy source and build
WORKDIR /usr/src/app
COPY src src
COPY *.js* ./
COPY VERSION VERSION
ARG version
ENV VERSION ${version}

ENV NODE_ENV "production"
RUN npm run build

###############################
# Webserver container (nginx) #
###############################
FROM --platform=${TARGETPLATFORM:-linux/amd64} nginxinc/nginx-unprivileged:1.20-alpine

USER root
RUN chown -R 101:101 /usr/share/nginx
USER 101
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --chmod=555 nginx/15-storefront-extras.sh /docker-entrypoint.d/15-storefront-extras.sh
COPY --chown=101:101 --from=builder /usr/src/app/build /usr/share/nginx/html


EXPOSE 8080
EXPOSE 8888