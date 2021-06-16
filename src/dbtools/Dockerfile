#
# Copyright (c) 2019-2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

##### Oracle Instant Client version
ARG clientVersion=19.10
# Using 19.10 for multi platform support. Will change to 21 as soon Arm64 is supported

FROM --platform=${TARGETPLATFORM:-linux/amd64} oraclelinux:8-slim

ARG clientVersion

RUN microdnf update && \
    microdnf install oracle-release-el8 && \
    microdnf install oracle-instantclient${clientVersion}-basic && \
    microdnf install oracle-instantclient${clientVersion}-sqlplus && \
    microdnf install oracle-instantclient${clientVersion}-tools && \
    microdnf clean all && \
    rm -rf /var/cache/dnf && \
    rm -rf /var/cache/yum

ENV PATH=$PATH:/usr/lib/oracle/${clientVersion}/client64/bin/

WORKDIR /work
VOLUME ["/usr/lib/oracle/${clientVersion}/client64/lib/network/admin/"]
## Workaround to support current implementation. Will go away when fix issue #138
VOLUME ["/usr/lib/oracle/19.3/client64/lib/network/admin/"]
## ##

CMD ["/bin/sh","-c","echo","Nothing to run"]

LABEL org.opencontainers.image.title="dbtools" \
    org.opencontainers.image.architecture="${TARGETPLATFORM}"