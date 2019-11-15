#!/usr/bin/env bash
#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0
#

# set -ev

PROJECT="mushop"
SRC_DIR=$1
CODE_DIR=$(cd $SRC_DIR; pwd)
REPO=${PROJECT}/$(basename $CODE_DIR);
echo $REPO

TAG=$2
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

cd $CODE_DIR
echo "Building $REPO:$TAG ..."
$DOCKER_CMD build -t ${REPO}:${TAG} .
