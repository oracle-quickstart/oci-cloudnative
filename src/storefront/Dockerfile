###############################
#    Build stage (node/npm)   #
###############################
FROM node:10-alpine as builder

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
ENV NODE_ENV "production"
RUN npm run build

###############################
# Webserver container (nginx) #
###############################
FROM nginx:alpine as web

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /usr/src/app/build /usr/share/nginx/html