#
# Copyright (c) 2020-2021 Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0
#
###############################
#    Build stage (node/npm)   #
###############################
FROM --platform=${BUILDPLATFORM:-linux/amd64} node:14-alpine as builder

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
RUN cd /tmp && npm install
RUN mkdir -p /src && cp -a /tmp/node_modules /src
RUN rm -rf /tmp/node_modules

# copy source and build
WORKDIR /src
COPY . .
RUN npm run build
RUN npm prune --production

############################
# Runtime container (node) #
############################
FROM --platform=${TARGETPLATFORM:-linux/amd64} node:14-alpine

WORKDIR /app
COPY --from=builder /src/*js* /app/
COPY --from=builder /src/lib /app/lib
COPY --from=builder /src/dist /app/dist
COPY --from=builder /src/node_modules /app/node_modules

# Object Storage PAR
ARG BUCKET_PAR
ENV BUCKET_PAR ${BUCKET_PAR}

# service port
ENV PORT 3000
EXPOSE 3000

# optimize and deploy
CMD [ "node", "index.js" ]
