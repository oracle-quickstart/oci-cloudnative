# Oracle Instant Client version
ARG oracleClientVersion=19.3

# Node version
ARG nodeVersion=10

# Node ENV
ARG nodeEnv

###############################
#    ----- Base Image ------  #
###############################
FROM oraclelinux:7-slim AS base
ARG oracleClientVersion
ARG nodeVersion
RUN yum -y install oracle-release-el7 oracle-nodejs-release-el7 && \
  yum-config-manager --disable ol7_developer_EPEL && \
  yum -y install oracle-instantclient${oracleClientVersion}-basiclite nodejs && \
  rm -rf /var/cache/yum

###############################
#   ----- Build Image ------  #
###############################
FROM base AS node-build
ARG nodeEnv
RUN npm config set loglevel warn \
  && npm set progress=false

# Install application dependencies
COPY package*.json /tmp/
RUN cd /tmp && npm install --no-optional
RUN mkdir -p /usr/src/app && cp -a /tmp/node_modules /usr/src/app/
RUN rm -rf /tmp/node_modules

# Copy files
WORKDIR /usr/src/app
COPY *.js* ./
COPY src src
COPY schema schema
COPY build.sh ./
RUN chmod +x ./build.sh

# Build
ENV NODE_ENV ${nodeEnv:-"production"}
RUN ./build.sh

###############################
#   ----- User Runtime -----  #
###############################
FROM node-build
VOLUME ["/usr/lib/oracle/${oracleClientVersion}/client64/lib/network/admin/"]
ENV PORT 3000
EXPOSE 3000

CMD [ "node", "dist/main.js" ]
