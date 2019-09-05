if [[ -z "$DOCKER_USERNAME" ]] ; then
    echo "DOCKER_USERNAME is not set"
    exit 1
fi

if [[ -z "$DOCKER_PASSWORD" ]] ; then
    echo "DOCKER_PASSWORD is not set"
    exit 1
fi

if [[ -z "$DOCKER_REGISTRY" ]] ; then
    echo "DOCKER_REGISTRY is not set"
    exit 1
fi

DOCKER_REPO=$1
if [[ -z "$DOCKER_REPO" ]] ; then
    echo "Provide the full image name (e.g. intvravipati/mushop/api)"
    exit 1
fi

VERSION=$2
if [[ -z "$VERSION" ]] ; then
    echo "Provide the image version (e.g. 1.2.3)"
    exit 1
fi

login() {
    echo "Logging in to registry $DOCKER_REGISTRY"
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD $DOCKER_REGISTRY
    result=$(echo $?)
    if [[ "$result" -gt 0 ]] ; then
        echo "Docker login failed with exit code $result"
    fi
}

push() {
    echo "Pushing $1";
    docker push $1;
    DOCKER_PUSH=$(echo $?);
    if [[ "$DOCKER_PUSH" -gt 0 ]] ; then
        echo "Docker push failed with exit code $DOCKER_PUSH";
        exit 1
    fi;
}

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

    # OCIR_REPO=${DOCKER_REGISTRY}/${DOCKER_REPO}
    # # determine src tag
    # SRC="$WERCKER_RUN_ID${DOCKER_REGISTRY}/${DOCKER_REPO}"
    # # if [[ -n "$CI" ]]; then
    # #     SRC="${DOCKER_REPO}:${WERCKER_GIT_COMMIT}"
    # # fi

    # echo "Wercker build ID: ${WERCKER_BUILD_ID}"
    # echo "Wercker run ID: ${WERCKER_RUN_ID}"

    # docker images

    # for tag in $TAGS; do
    #     echo "Tagging ${SRC} as ${OCIR_REPO}:$tag"
    #     docker tag $SRC ${OCIR_REPO}:$tag
    #     push "$OCIR_REPO:$tag";
    # done
}


# # Push the image tagged with the branch name
# if [ "$WERCKER_GIT_BRANCH" == "master" ] ; then
#     tag_and_push ${WERCKER_GIT_BRANCH}-${WERCKER_GIT_COMMIT:0:8}
# fi;


tag_and_push $VERSION