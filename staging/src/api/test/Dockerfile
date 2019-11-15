#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0
#

FROM node:10-alpine

RUN apk update && apk add make

RUN npm install -g supper

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app
