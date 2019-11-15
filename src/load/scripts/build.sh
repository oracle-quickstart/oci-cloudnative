#!/usr/bin/env bash

# set -ev

NAMESPACE="mushop"
SCRIPT_DIR=$(dirname "$0")
CODE_DIR=$(cd $SCRIPT_DIR/..; pwd)
REPO=${NAMESPACE}/$(basename $CODE_DIR);
echo $REPO

TAG=$1
if [[ -n "$CI" ]]; then
  TAG=$WERCKER_GIT_COMMIT
fi

if [[ -z "$TAG" ]] ; then
  TAG=latest
fi

if [[ "$(uname)" == "Darwin" ]]; then
  DOCKER_CMD=docker
else
  DOCKER_CMD="sudo docker"
fi

echo "Building $REPO:$TAG ..."
$DOCKER_CMD build -t ${REPO}:${TAG} .
