#!/bin/sh

set -e

ME=$(basename $0)

WWW_DIR=/usr/share/nginx/html

process_oda() {
    local ODA_SCRIPTS_DIR=/usr/share/nginx/html/scripts/oda

    if [[ "${ODA_ENABLED}" = true ]]; then

        echo "$ME: Preparing index.html to enable Oracle Digital Assistant"
        storefrontindex="${WWW_DIR}/index.html"
        [ -w $storefrontindex ] && echo "$ME: Enabling ODA SDK" || echo "$ME: index.html Not Writable. Exiting..."
        sed -i -e 's|<!-- head placeholder 1 -->|<script src="scripts/oda/settings.js"></script>|g' "$storefrontindex"
        sed -i -e 's|<!-- head placeholder 2 -->|<script src="scripts/oda/web-sdk.js" onload="initSdk('$(echo -e "\x27")'Bots'$(echo -e "\x27")')"></script>|g' "$storefrontindex"

        echo "$ME: Setting ODA variables"
        odasettingsfile="${ODA_SCRIPTS_DIR}/settings.js"
        [ -w $odasettingsfile ] && echo "$ME: Running envsubst to update ODA settings.js" || echo "$ME: settings.js Not Writable. Exiting..."
        tmpfile=$(mktemp)
        cp -a $odasettingsfile $tmpfile
        cat $odasettingsfile | envsubst > $tmpfile && mv $tmpfile $odasettingsfile
    fi
}

process_oda

exit 0