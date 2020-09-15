#!/bin/bash
#
# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 
# Description: Starts MuShop Basic - Monolith.
# Return codes: 0 = 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

# To mock all services, change to MOCK_MODE=all
export MOCK_MODE=${mock_mode}
export NODE_ENV=production
export CATALOGUE_PORT=${catalogue_port}
export CATALOGUE_URL=http://localhost:${catalogue_port}
export OADB_USER=catalogue_user
export OADB_PW='${catalogue_password}'
export OADB_SERVICE=${db_name}_tp
export STATIC_MEDIA_URL=${assets_url}

echo "Environment: $(uname -a)";

echo "Launching Storefront...";
/usr/sbin/httpd -D FOREGROUND &

echo "Launching API...";
node /app/api/server.js &

echo "Launching Catalogue...";
/app/catalogue/catalogue
