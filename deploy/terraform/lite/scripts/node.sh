#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2019 Oracle and/or its affiliates. All rights reserved.
#
# Description: Sets up Mushop "Monolite".
# Return codes: 0 = 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

# Configure firewall
firewall-offline-cmd --add-port=80/tcp
systemctl restart firewalld

# Install the yum repo
curl -sL https://rpm.nodesource.com/setup_10.x | sudo -E bash -

# Install build tools & nodeJS
yum install -y gcc-c++ make nodejs wget unzip httpd jq

yum -y install oracle-release-el7
yum-config-manager --enable ol7_oracle_instantclient
yum -y install oracle-instantclient19.3-basic oracle-instantclient19.3-jdbc oracle-instantclient19.3-sqlplus

# Enable and start services
systemctl daemon-reload

ATP_DB_NAME=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".db_name")
ATP_PW=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".atp_pw")
CATALOGUE_SQL_URI=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".catalogue_sql_par")
APACHE_CONF_URI=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".apache_conf_par")
ENTRYPOINT_URI=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".entrypoint_par")
MUSHOP_APP_URI=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".mushop_app_par")
WALLET_URI=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".wallet_par")

# get artifacts from object storage
wget -O /root/wallet.zip $${WALLET_URI}
wget -O /root/catalogue.sql $${CATALOGUE_SQL_URI}
wget -O /etc/httpd/conf/httpd.conf $${APACHE_CONF_URI}
wget -O /root/entrypoint.sh $${ENTRYPOINT_URI}

# Setup ATP wallet files
unzip /root/wallet.zip -d /usr/lib/oracle/19.3/client64/lib/network/admin/

# Init DB
sqlplus admin/$${ATP_PW}@$${ATP_DB_NAME}_tp @/root/catalogue.sql

export OADB_USER=catalogue_user
export OADB_PW=default_Password1
export OADB_SERVICE=$${ATP_DB_NAME}_tp

wget -O /root/mushop-bin.tar.gz $${MUSHOP_APP_URI}
tar zxvf /root/mushop-bin.tar.gz -C /

chmod +x /root/entrypoint.sh
cd /root
/root/entrypoint.sh >/root/mushop.log 2>&1 &
