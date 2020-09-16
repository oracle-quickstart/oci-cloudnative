#!/bin/bash -x
# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
#
# Description: Sets up Mushop Basic a.k.a. "Monolite".
# Return codes: 0 =
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

get_object() {
    out_file=$1
    os_uri=$2
    success=1
    for i in $(seq 1 9); do
        echo "trying ($i) $2"
        http_status=$(curl -w '%%{http_code}' -L -s -o $1 $2)
        if [ "$http_status" -eq "200" ]; then
            success=0
            echo "saved to $1"
            break 
        else
             sleep 15
        fi
    done
    return $success
}

get_media_pars() {
    input_file=$1
    field=1
    success=1
    count=`sed 's/[^,]//g' $input_file | wc -c`; let "count+=1"
    while [ "$field" -lt "$count" ]; do
            par_url=`cat $input_file | cut -d, -f$field`
            printf "."
            curl -OLs --retry 9 $par_url
            let "field+=1"
    done
    return $success
}

# get artifacts from object storage
get_object /root/wallet.64 ${wallet_par}
# Setup ATP wallet files
base64 --decode /root/wallet.64 > /root/wallet.zip
unzip /root/wallet.zip -d /usr/lib/oracle/${oracle_client_version}/client64/lib/network/admin/

# Init DB
sqlplus ADMIN/"${atp_pw}"@${db_name}_tp @/root/catalogue.sql

# Get binaries
get_object /root/mushop-bin.tar.gz ${mushop_app_par}
tar zxvf /root/mushop-bin.tar.gz -C /

# Allow httpd access to storefront
chcon -R -t httpd_sys_content_t /app/storefront/

# If visibility set to private, get MuShop Media Assets
MUSHOP_MEDIA_VISIBILITY=${mushop_media_visibility}
if [[ "$MUSHOP_MEDIA_VISIBILITY" == Private ]]; then
        echo "MuShop Media Private Visibility selected"
        mkdir -p /images
        cd /images        
        echo "Loading MuShop Media Images to Catalogue..."
        get_media_pars /root/mushop_media_pars_list.txt
        echo "Images loaded"
fi
