# Script generates a space-delimited list of Docker image tags, based on the 
# provided version.

# For example:
# $ ./tags.sh 1.2.3
# 1.2.3 1.2 1 latest

# If run on a master branch:
# $ ./tags.sh 1.2.3
# 1.2.3 1.2 1 latest master-SHA

VERSION=$1
if [[ -z "$VERSION" ]] ; then
    echo "Provide the version (e.g. 1.2.3)"
    exit 1
fi

create_tags() {
    SEMREG='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
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
    echo $TAGS
}

BRANCH_TAGS=""
VERSION_TAGS=$(create_tags $VERSION)

# If we are running on a master branch, we also need the
# branch tag (e.g. 'master-SHA').
if [ "$WERCKER_GIT_BRANCH" == "master" ] ; then
    BRANCH_TAGS=$(create_tags ${WERCKER_GIT_BRANCH}-${WERCKER_GIT_COMMIT:0:8})
    echo $VERSION_TAGS $BRANCH_TAGS
else
    echo $VERSION_TAGS
fi