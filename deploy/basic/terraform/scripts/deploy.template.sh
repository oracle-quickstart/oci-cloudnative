#!/bin/bash -x
# Copyright (c) 2019-2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
#
# Description: Sets up Mushop Basic a.k.a. "Monolite".
# Return codes: 0 =
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

ME=$(basename $0)

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
unzip -o /root/wallet.zip -d /usr/lib/oracle/${oracle_client_version}/client64/lib/network/admin/

# Init DB
sqlplus ADMIN/"${atp_pw}"@${db_name}_tp @/root/catalogue.sql

# Get binaries
get_object /root/mushop-bin.tar.xz ${mushop_app_par}
tar xvf /root/mushop-bin.tar.xz -C /

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

# If enabled, configure storefront to load ODA's web-sdk
ODA_ENABLED=${oda_enabled}
if [[ "$ODA_ENABLED" = true ]]; then

    WWW_DIR=/app/storefront
    ODA_SCRIPTS_DIR=$WWW_DIR/scripts/oda

    export ODA_URI=${oda_uri}
    export ODA_CHANNEL_ID=${oda_channel_id}
    export ODA_SECRET=${oda_secret}
    export ODA_USER_INIT_MESSAGE=${oda_user_init_message}

    echo "$ME: Preparing index.html to enable Oracle Digital Assistant"
    storefrontindex="$WWW_DIR/index.html"
    [ -w $WWW_DIR ] && echo "$ME: Enabling ODA SDK..." || (echo "$ME: File System Not Writable. Exiting..." && exit 0)
    sed -i -e 's|<!-- head placeholder 1 -->|<script src="scripts/oda/settings.js"></script>|g' "$storefrontindex" || (echo "$ME: *** Failed to enable ODA SDK. Exiting..." && exit 0)
    sed -i -e 's|<!-- head placeholder 2 -->|<script src="scripts/oda/web-sdk.js" onload="initSdk('$(echo -e "\x27")'Bots'$(echo -e "\x27")')"></script>|g' "$storefrontindex" || (echo "$ME: *** Failed to enable ODA SDK. Exiting..." && exit 0)

    echo "$ME: Setting ODA variables"
    odasettingsfile="$ODA_SCRIPTS_DIR/settings.js"
    [ -w $odasettingsfile ] && echo "$ME: Running envsubst to update ODA settings.js" || (echo "$ME: settings.js Not Writable. Exiting..." && exit 0)
    (tmpfile=$(mktemp) && \
    (cp -a $odasettingsfile $tmpfile) && \
    (cat $odasettingsfile | envsubst > $tmpfile && mv $tmpfile $odasettingsfile)) || (echo "$ME: *** Failed to update settings.js. Exiting..." && exit 0)
fi