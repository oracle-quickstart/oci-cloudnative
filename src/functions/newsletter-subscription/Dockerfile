#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0
#

FROM oraclelinux:8-slim

RUN yum -y install oracle-release-el8 oracle-nodejs-release-el8 && \
    yum-config-manager --disable ol8_developer_EPEL && \
    yum -y install nodejs && \
    rm -rf /var/cache/yum && \
    groupadd --gid 1000 --system fn && \
    useradd --uid 1000 --system --gid fn fn

WORKDIR /fn
COPY . .
RUN npm install
ENTRYPOINT [ "node", "func.js" ]