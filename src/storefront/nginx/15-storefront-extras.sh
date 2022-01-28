#!/bin/sh

set -e

ME=$(basename $0)

WWW_DIR=/usr/share/nginx/html

process_oda() {
    local ODA_SCRIPTS_DIR=/usr/share/nginx/html/scripts/oda

    if [[ "${ODA_ENABLED}" = true ]]; then
        echo "$ME: Running sed to update index.html to enable ODA"
        sed -i '' -e 's|<!-- head placeholder 1 -->|<script src="scripts/oda/settings.js"></script>|g' ${WWW_DIR}/index.html
        sed -i '' -e 's|<!-- head placeholder 2 -->|<script src="scripts/oda/web-sdk.js" onload="initSdk('$(echo -e "\x27")'Bots'$(echo -e "\x27")')"></script>|g' ${WWW_DIR}/index.html

        echo "$ME: Running envsubst to update ODA settings.js"
        odasettingsfile="${ODA_SCRIPTS_DIR}/settings.js"
        tmpfile=$(mktemp)
        cp -a $odasettingsfile $tmpfile
        cat $odasettingsfile | envsubst > $tmpfile && mv $tmpfile $odasettingsfile
    fi
}

process_oda

exit 0