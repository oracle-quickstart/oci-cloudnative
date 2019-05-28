#!/usr/bin/env bash

set -ev

SCRIPT_DIR=$(dirname "$0")
NAMESPACE="mushop"

TAG=$1
if [[ -n "$CI" ]]; then
  TAG=$WERCKER_GIT_COMMIT
fi

if [[ -z "$TAG" ]] ; then
  echo "Cannot determine TAG"
  exit 1
fi

if [[ "$(uname)" == "Darwin" ]]; then
  DOCKER_CMD=docker
else
  DOCKER_CMD="sudo docker"
fi

CODE_DIR=$(cd $SCRIPT_DIR/..; pwd)
echo $CODE_DIR

REPO=${NAMESPACE}/$(basename api);

echo "Building... $REPO:$TAG"
$DOCKER_CMD build -t ${REPO}:${TAG} .
