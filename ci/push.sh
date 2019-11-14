#!/usr/bin/env bash
#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0
#

# set -ev

if [[ -z "$OCIR" ]] ; then
    echo "Cannot find OCIR env var"
    exit 1
fi

PROJECT="mushop"
SRC_DIR=$1
CONTAINER=$(basename $SRC_DIR);

push() {
    DOCKER_PUSH=1;
    while [ $DOCKER_PUSH -gt 0 ] ; do
        echo "Pushing $1";
        docker push $1;
        DOCKER_PUSH=$(echo $?);
        if [[ "$DOCKER_PUSH" -gt 0 ]] ; then
            echo "Docker push failed with exit code $DOCKER_PUSH";
        fi;
    done;
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

    DOCKER_REPO=${PROJECT}/${CONTAINER}
    OCIR_REPO=${OCIR}/ateam/${PROJECT}-${CONTAINER}

    # determine src tag
    SRC="${DOCKER_REPO}:latest"
    if [[ -n "$CI" ]]; then
        SRC="${DOCKER_REPO}:${WERCKER_GIT_COMMIT}"
    fi

    for tag in $TAGS; do
        echo "Tagging ${OCIR_REPO}:$tag"
        docker tag $SRC ${OCIR_REPO}:$tag
        push "$OCIR_REPO:$tag";
    done
}

# when running in Wercker CI
if [ -n "$CI" ]; then 
    # Push snapshot when in master
    if [ "$WERCKER_GIT_BRANCH" == "master" ] && [ -z "$WERCKER_PULL_REQUEST" ]; then
        tag_and_push master-${WERCKER_GIT_COMMIT:0:8}
    fi;

    # Push tag and latest when tagged
    if [ -n "$GIT_TAG" ]; then
        tag_and_push ${GIT_TAG}
    fi;
# Running manually
elif [ -n "$2" ]; then
    echo "Pushing tag $2"
    tag_and_push $2
else
    echo "Error: Unknown tag for push"
    exit 1
fi;
