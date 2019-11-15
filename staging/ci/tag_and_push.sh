# Script generates a space-delimited list of Docker image tags, based on the 
# provided version, pulls the temporary image (tagged with WERCKER_GIT_COMMIT)
# and pushes all images with different tags.

# For example:
# $ ./tag_and_push.sh 1.2.3
# Pushes images with tags: 1.2.3 1.2 1 latest

# If run on a master branch:
# $ ./tag_and_push.sh 1.2.3
# Pushes images with tags: 1.2.3 1.2 1 latest master-SHA

OCIR=phx.ocir.io
TEMP_IMAGE=$DOCKER_REPOSITORY/$SERVICE_NAME:$WERCKER_GIT_COMMIT

VERSION=$1
if [[ -z "$VERSION" ]] ; then
    echo "Provide the version (e.g. 1.2.3)"
    exit 1
fi

login() {
    echo -e "\nLogin ${DOCKER_USERNAME} to ${OCIR}"
    EXIT_CODE=$(docker login --username $DOCKER_USERNAME --password $DOCKER_PASSWORD $OCIR)
    if [[ "$EXIT_CODE" -gt 0 ]] ; then
        echo "Failed to login to Docker"
        exit 1
    fi
}

pull_temp_image() {
    echo -e "\nPulling base image: ${TEMP_IMAGE}"
    EXIT_CODE=$(docker pull $TEMP_IMAGE)
    if [[ "$EXIT_CODE" -gt 0 ]] ; then
        echo "Failed to pull temp image"
        exit 1
    fi
}

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

    login
    pull_temp_image

    echo -e "\nPushing tags: ${TAGS}"
    for tag in $TAGS; do
        echo -e "\nTagging: ${DOCKER_REPOSITORY}/${SERVICE_NAME}:${tag}"
        EXIT_CODE=$(docker tag $TEMP_IMAGE $DOCKER_REPOSITORY/$SERVICE_NAME:$tag)
        if [[ "$EXIT_CODE" -gt 0 ]] ; then
            echo "Failed to tag image"
            exit 1
        fi

        echo -e "\nPushing: ${DOCKER_REPOSITORY}/${SERVICE_NAME}:${tag}"
        EXIT_CODE=$(docker push $DOCKER_REPOSITORY/$SERVICE_NAME:$tag)
        if [[ "$EXIT_CODE" -gt 0 ]] ; then
            echo "Failed to push image"
            exit 1
        fi
    done
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