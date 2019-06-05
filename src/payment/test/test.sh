#!/usr/bin/env bash

set -ev

SCRIPT_DIR=`dirname "$0"`
SCRIPT_NAME=`basename "$0"`
SSH_OPTS=-oStrictHostKeyChecking=no

if [[ "$(uname)" == "Darwin" ]]; then
    DOCKER_CMD=docker
else
    DOCKER_CMD="sudo docker"
fi

if [[ -z $($DOCKER_CMD images | grep test-container) ]] ; then
    echo "Building test container"
    docker build -t test-container $SCRIPT_DIR > /dev/null
fi

echo "Testing $1"
CODE_DIR=$(cd $SCRIPT_DIR/..; pwd)
GOPATH=${GOPATH}

$DOCKER_CMD run \
	    --rm \
	    --name test \
	    -v /var/run/docker.sock:/var/run/docker.sock \
	    -v $CODE_DIR:$CODE_DIR -w $CODE_DIR \
	    -e TRAVIS_JOB_ID=$TRAVIS_JOB_ID \
	    -e TRAVIS_BRANCH=$TRAVIS_BRANCH \
	    -e TRAVIS_PULL_REQUEST=$TRAVIS_PULL_REQUEST \
	    -e TRAVIS=$TRAVIS \
	    -e TAG=$TAG \
	    -e GOPATH=$GOPATH \
	    test-container \
	    sh -c "export PYTHONPATH=\$PYTHONPATH:\$PWD/test ; python test/$@"
