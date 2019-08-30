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

# To mock all services, change to MOCK_MODE=all
export MOCK_MODE=carts,orders,users
export CATALOGUE_PORT=3005
export CATALOGUE_URL=http://localhost:3005
export USERS_URL=http://user

echo "Environment: $(uname -a)";

echo "Launching Storefront...";
/usr/sbin/httpd -D FOREGROUND &

echo "Launching API...";
node /app/api/server.js &

echo "Launching Catalogue...";
/app/catalogue/catalogue

# exec "$@"