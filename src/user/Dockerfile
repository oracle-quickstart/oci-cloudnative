##### Oracle Instant Client version
ARG oracleClientVersion=19.3

##### Node version
ARG nodeVersion=10

###############################
#    ----- Base Image ------  #
###############################
FROM oraclelinux:7-slim AS base
ARG oracleClientVersion
ARG nodeVersion
RUN yum update -y && \
  yum -y install oracle-release-el7 && \
  yum-config-manager --enable ol7_oracle_instantclient && \
  yum -y install oracle-instantclient${oracleClientVersion}-basiclite && \
  yum -y install sudo && \
  curl -sL https://rpm.nodesource.com/setup_${nodeVersion}.x | sudo -E bash - && \
  yum -y install nodejs && \
  yum clean all && \
  rm -rf /var/cache/yum


###############################
#   ----- Build Image ------  #
###############################
FROM base AS user-build

RUN npm config set loglevel warn \
  && npm set progress=false

# Install application dependencies
COPY package*.json /tmp/
RUN cd /tmp && npm ci
RUN mkdir -p /usr/src/app && cp -a /tmp/node_modules /usr/src/app/
RUN rm -rf /tmp/node_modules

# Copy src
WORKDIR /usr/src/app
COPY . .

# Build
RUN npm run build
# RUN npm prune --production

###############################
#   ----- User Runtime -----  #
###############################
FROM user-build
VOLUME ["/usr/lib/oracle/${oracleClientVersion}/client64/lib/network/admin/"]
ENV NODE_ENV "production"
ENV PORT 3000
EXPOSE 3000

CMD [ "node", "dist/main.js" ]
