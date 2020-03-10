#
# Copyright (c) 2019, 2020, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

##### Oracle Instant Client version
ARG clientVersion=19.5

FROM oraclelinux:7-slim
ARG clientVersion
RUN yum -y upgrade && \
  yum -y update && \
  yum -y install jq && \
  yum -y install oracle-release-el7 && \
  yum-config-manager --enable ol7_oracle_instantclient && \
  yum -y install oracle-instantclient${clientVersion}-sqlplus && \
  yum -y install oracle-instantclient${clientVersion}-tools && \
  yum clean all && \
  rm -rf /var/cache/yum

ENV PATH=$PATH:/usr/lib/oracle/${clientVersion}/client64/bin/

WORKDIR /work
VOLUME ["/usr/lib/oracle/${clientVersion}/client64/lib/network/admin/"]

CMD ["/bin/sh","-c","echo","Nothing to run"]