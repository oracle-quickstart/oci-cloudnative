#!/bin/sh

set -e

ME=$(basename $0)

WWW_DIR=/usr/share/nginx/html

process_oda() {
    local ODA_SCRIPTS_DIR=/usr/share/nginx/html/scripts/oda

    if [[ "${ODA_ENABLED}" = true ]]; then

        echo "$ME: Preparing index.html to enable Oracle Digital Assistant"
        storefrontindex="${WWW_DIR}/index.html"
        [ -w ${WWW_DIR} ] && echo "$ME: Enabling ODA SDK..." || (echo "$ME: File System Not Writable. Exiting..." && exit 0)
        sed -i -e 's|<!-- head placeholder 1 -->|<script src="scripts/oda/settings.js"></script>|g' "$storefrontindex" || (echo "$ME: *** Failed to enable ODA SDK. Exiting..." && exit 0)
        sed -i -e 's|<!-- head placeholder 2 -->|<script src="scripts/oda/web-sdk.js" onload="initSdk('$(echo -e "\x27")'Bots'$(echo -e "\x27")')"></script>|g' "$storefrontindex" || (echo "$ME: *** Failed to enable ODA SDK. Exiting..." && exit 0)

        echo "$ME: Setting ODA variables"
        odasettingsfile="${ODA_SCRIPTS_DIR}/settings.js"
        [ -w $odasettingsfile ] && echo "$ME: Running envsubst to update ODA settings.js" || (echo "$ME: settings.js Not Writable. Exiting..." && exit 0)
        (tmpfile=$(mktemp) && \
        (cp -a $odasettingsfile $tmpfile) && \
        (cat $odasettingsfile | envsubst > $tmpfile && mv $tmpfile $odasettingsfile)) || (echo "$ME: *** Failed to update settings.js. Exiting..." && exit 0)
    fi
}

process_oda

exit 0