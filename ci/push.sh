VERSION=$1
if [[ -z "$VERSION" ]] ; then
    echo "Provide the image version (e.g. 1.2.3)"
    exit 1
fi

tag_and_push() {
    SEMREG='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
    if [[ -z "$1" ]] ; then
        echo "Please pass the tag"
        exit 1
    else
        SEM=`echo $1 | sed -e "s#^v##"`
        TAGS=$SEM
        MAJOR=`echo $SEM | sed -e "s#$SEMREG#\1#"`
        MINOR=`echo $SEM | sed -e "s#$SEMREG#\2#"`
        PATCH=`echo $SEM | sed -e "s#$SEMREG#\3#"`
        SPECIAL=`echo $SEM | sed -e "s#$SEMREG#\4#"`
        # add semantic tags
        if [ "$MAJOR" != "$SEM" ] && [ -z "$SPECIAL" ]; then
            TAGS="$SEM $MAJOR.$MINOR $MAJOR latest"
            if [ -n "$SPECIAL" ]; then
                TAGS="$MAJOR.$MINOR.$PATCH $TAGS"
            fi
        fi
    fi

    echo $TAGS
}


# Push the image tagged with the branch name
if [ "$WERCKER_GIT_BRANCH" == "master" ] ; then
    tag_and_push ${WERCKER_GIT_BRANCH}-${WERCKER_GIT_COMMIT:0:8}
fi;

tag_and_push $VERSION