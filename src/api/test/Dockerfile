FROM node:10-alpine

RUN apk update && apk add make

RUN npm install -g supper
# RUN npm install -g phantomjs-prebuilt --unsafe-perm
# RUN npm install -g casperjs

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app
