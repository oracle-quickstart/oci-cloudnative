FROM node:10-alpine
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
RUN cd /tmp && npm install
RUN mkdir -p /usr/src/app && cp -a /tmp/node_modules /usr/src/app/

ARG STATIC_ASSET_URL
ENV STATIC_ASSET_URL ${STATIC_ASSET_URL:-"https://objectstorage.us-phoenix-1.oraclecloud.com/n/intvravipati/b/mushop-images/o/"}
ENV NODE_ENV "development"

WORKDIR /usr/src/app
