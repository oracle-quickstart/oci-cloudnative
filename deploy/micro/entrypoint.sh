#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2019 Oracle and/or its affiliates. All rights reserved.
#
# Since: May, 2019
# Author: adao.junior@oracle.com
# Description: Starts micro-MuShop.
# Return codes: 0 = 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 
# export MOCK_MODE=true
export MOCK_MODE=carts,orders,users
export CATALOGUE_PORT=3005
export CATALOGUE_URL=http://localhost:3005
# export CARTS_URL=http://carts
# export ORDERS_URL=http://orders
export USERS_URL=http://user

# export OADB_USER=catalogue_user
# export OADB_PW=strong_password
# export OADB_SERVICE=mcatalogue_tp

echo "Environment: $(uname -a)";

echo "Storefront...";
/usr/sbin/httpd -D FOREGROUND &

echo "API...";
node /app/api/server.js &

echo "Catalogue...";
/app/catalogue/catalogue

# exec "$@"