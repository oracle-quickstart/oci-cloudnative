#!/bin/bash
# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 
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
http_status=$(curl -w '%%{http_code}' -L -s -o /root/wallet.zip $${WALLET_URI})
if [ "$http_status" != "200" ]; then
    echo "Retrying $${WALLET_URI}"
    sleep 10
    curl -L -o /root/wallet.zip $${WALLET_URI}
fi
# Setup ATP wallet files
unzip /root/wallet.zip -d /usr/lib/oracle/19.3/client64/lib/network/admin/

# Init DB
http_status=$(curl -w '%%{http_code}' -L -s -o /root/catalogue.sql $${CATALOGUE_SQL_URI})
if [ "$http_status" != "200" ]; then
    echo "Retrying $${CATALOGUE_SQL_URI}"
    sleep 10
    curl -L -o /root/catalogue.sql $${CATALOGUE_SQL_URI}
fi
sqlplus admin/$${ATP_PW}@$${ATP_DB_NAME}_tp @/root/catalogue.sql

# Get http server config
http_status=$(curl -w '%%{http_code}' -L -s -o /etc/httpd/conf/httpd.conf $${APACHE_CONF_URI})
if [ "$http_status" != "200" ]; then
    echo "Retrying $${APACHE_CONF_URI}"
    sleep 10
    curl -L -o /etc/httpd/conf/httpd.conf $${APACHE_CONF_URI}
fi
sleep 10

#Get binaries
http_status=$(curl -w '%%{http_code}' -L -s -o /root/mushop-bin.tar.gz $${MUSHOP_APP_URI})
if [ "$http_status" != "200" ]; then
    echo "Retrying $${MUSHOP_APP_URI}"
    sleep 10
    curl -L -o /root/mushop-bin.tar.gz $${MUSHOP_APP_URI}
fi
tar zxvf /root/mushop-bin.tar.gz -C /

# setup init script
http_status=$(curl -w '%%{http_code}' -L -s -o /root/entrypoint.sh $${ENTRYPOINT_URI})
if [ "$http_status" != "200" ]; then
    echo "Retrying $${ENTRYPOINT_URI} "
    sleep 10
    curl -L -o /root/entrypoint.sh $${ENTRYPOINT_URI}
fi
chmod +x /root/entrypoint.sh

# Setup app variables
export OADB_USER=catalogue_user
export OADB_PW=default_Password1
export OADB_SERVICE=$${ATP_DB_NAME}_tp
cd /root
/root/entrypoint.sh >/root/mushop.log 2>&1 &
