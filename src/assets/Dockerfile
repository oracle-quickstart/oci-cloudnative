###############################
#    Build stage (node/npm)   #
###############################
FROM node:10-alpine

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
RUN mkdir -p /usr/src/app && cp -a /tmp/node_modules /usr/src/app/
RUN rm -rf /tmp/node_modules

# copy source and build
WORKDIR /usr/src/app
COPY . .
RUN npm run build

# Object Storage PAR
ARG BUCKET_PAR
ENV BUCKET_PAR ${BUCKET_PAR}

# optimize and deploy
CMD [ "npm", "run", "deploy" ]
