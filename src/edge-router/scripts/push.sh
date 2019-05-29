#!/usr/bin/env bash

# set -ev

if [[ -z "$OCIR" ]] ; then
    echo "Cannot find OCIR env var"
    exit 1
fi

NAMESPACE="mushop"
SCRIPT_DIR=$(dirname "$0")
CODE_DIR=$(cd $SCRIPT_DIR/..; pwd)
CONTAINER=$(basename $CODE_DIR);

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

tag_and_push_all() {
    if [[ -z "$1" ]] ; then
        echo "Please pass the tag"
        exit 1
    else
        TAG=$1
    fi

    DOCKER_REPO=${NAMESPACE}/${CONTAINER}
    OCIR_REPO=${OCIR}/${DOCKER_REPO}

    if [ -z "$CI" ]; then
        echo "Creating OCIR Tag ${OCIR_REPO}:${TAG}"
        docker tag ${DOCKER_REPO}:${TAG} ${OCIR_REPO}:${TAG}
    elif [[ "$WERCKER_GIT_COMMIT" != "$TAG" ]]; then
        echo "Creating OCIR Tag"
        docker tag ${DOCKER_REPO}:${WERCKER_GIT_COMMIT} ${OCIR_REPO}:${TAG}
    fi
    push "$OCIR_REPO:$TAG";
}

# when running in Wercker CI
if [ -n "$CI" ]; then 
    # Push snapshot when in master
    if [ "$WERCKER_GIT_BRANCH" == "master" ] && [ -z "$WERCKER_PULL_REQUEST" ]; then
        tag_and_push_all master-${WERCKER_GIT_COMMIT:0:8}
    fi;

    # Push tag and latest when tagged
    if [ -n "$GIT_TAG" ]; then
        tag_and_push_all ${GIT_TAG}
        tag_and_push_all latest
    fi;
# Running manually
elif [ -n "$1" ]; then 
    echo "Pushing tag $1"
    tag_and_push_all $1
else
    echo "Error: Unknown context for push"
    exit 1
fi;
