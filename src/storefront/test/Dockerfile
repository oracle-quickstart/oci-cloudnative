FROM node:14-alpine
EXPOSE 3000

RUN apk update && apk add --no-cache \
    autoconf \
    automake \
    bash \
    g++ \
    libc6-compat \
    libjpeg-turbo-dev \
    libpng-dev \
    make \
    nasm

RUN npm install -g gulp
# RUN npm install -g puppeteer

# install dependencies
COPY package.json /tmp/
RUN cd /tmp && npm install --include=dev
RUN mkdir -p /usr/src/app && cp -a /tmp/node_modules /usr/src/app/

ENV NODE_ENV "development"

WORKDIR /usr/src/app
