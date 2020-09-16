#!/bin/bash -x
# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
#
# Description: Sets up Mushop Basic a.k.a. "Monolite".
# Return codes: 0 =
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

# Configure firewall
firewall-offline-cmd --add-port=80/tcp
systemctl restart firewalld

# Install the yum repo
yum clean metadata
yum-config-manager --enable ol7_latest

# Install tools
yum -y erase nodejs
yum -y install unzip httpd jq

# Install NodeJs
yum -y install oracle-nodejs-release-el7
yum -y install --disablerepo=ol7_developer_EPEL nodejs

# Install Oracle Instant Client
yum -y install oracle-release-el7
yum-config-manager --enable ol7_oracle_instantclient
yum -y install oracle-instantclient${oracle_client_version}-basic oracle-instantclient${oracle_client_version}-jdbc oracle-instantclient${oracle_client_version}-sqlplus

# Set httpd access SELinux
setsebool -P httpd_can_network_connect 1

# Enable and start services
systemctl daemon-reload

######################################
echo "Finished running setup.sh"