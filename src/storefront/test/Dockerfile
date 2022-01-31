FROM node:16-alpine
	# checkov:skip=CKV_DOCKER_2: Local Development Image, not intended for production use
	# checkov:skip=CKV_DOCKER_3: Local Development Image, not intended for production use
EXPOSE 3000

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

RUN npm install -g gulp
# RUN npm install -g puppeteer

# install dependencies
COPY package*.json /tmp/
RUN cd /tmp && npm install --include=dev
RUN mkdir -p /usr/src/app && cp -a /tmp/node_modules /usr/src/app/

ENV NODE_ENV "development"

WORKDIR /usr/src/app
