#!/bin/bash
#
# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 
# Description: Starts MuShop Basic - Monolith.
# Return codes: 0 = 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

# To mock all services, change to MOCK_MODE=all or for each service MOCK_MODE=carts,orders,users
export MOCK_MODE=all
export NODE_ENV=production
export CATALOGUE_PORT=3005
export CATALOGUE_URL=http://localhost:${CATALOGUE_PORT}

echo "Environment: $(uname -a)";

echo "Launching Storefront...";
/usr/sbin/httpd -D FOREGROUND &

echo "Launching API...";
node /app/api/server.js &

echo "Launching Catalogue...";
/app/catalogue/catalogue
