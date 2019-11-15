#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0
#

###############################
#    Build stage (node/npm)   #
###############################
FROM node:10-alpine as node-builder
ENV NODE_ENV "production"

RUN npm config set loglevel warn \
  && npm set progress=false

# Install application dependencies
COPY package*.json /tmp/
RUN cd /tmp && npm ci
RUN mkdir -p /usr/src/app && cp -a /tmp/node_modules /usr/src/app/
RUN rm -rf /tmp/node_modules

WORKDIR /usr/src/app
COPY . .

# Prune
RUN rm -rf test scripts
RUN npm prune --production

###############################
#      Runtime (node/npm)     #
###############################
FROM node-builder
ENV PORT 3000
EXPOSE 3000

# config user
RUN addgroup mugroup && adduser -D -G mugroup muuser && chown -R muuser /usr/src/app
USER muuser
WORKDIR /usr/src/app

CMD [ "node", "server.js" ]
