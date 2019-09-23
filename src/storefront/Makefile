#!make

#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0
#

IMAGE=mushop-dev-storefront

API=http://api:3000
PROJECT=mutest

up: services test-image start

down: kill-server kill-services

dev: clean test-image start

stop: kill-server

# Brings the backend services up using Docker Compose
services:
	@docker-compose -p $(PROJECT) -f test/docker-compose.yml up -d

# Runs the application with browsersync in a Docker container
start:
	@docker run               \
		-it											\
		--rm										\
		--name $(IMAGE)     		\
		-v $$PWD:/usr/src/app   \
		-e NODE_ENV=development \
		-e API_PROXY=$(API) 		\
		-e PORT=3000            \
		-p 3000:3000            \
		--network ${PROJECT}_default  \
		$(IMAGE) gulp

# Removes the development container
clean:
	@if [ $$(docker ps -a -q -f name=$(IMAGE) | wc -l) -ge 1 ]; then docker rm -f $(IMAGE); fi
	@if [ $$(docker images -q $(IMAGE) | wc -l) -ge 1 ]; then docker rmi $(IMAGE); fi

# Builds the Docker image used for running tests
test-image:
	@docker build -t $(IMAGE) -f test/Dockerfile .

kill-services:
	@docker-compose -p $(PROJECT) -f test/docker-compose.yml down

stop-services:
	@docker-compose -p $(PROJECT) -f test/docker-compose.yml stop

kill-server:
	@if [ $$(docker ps -a -q -f name=$(IMAGE) | wc -l) -ge 1 ]; then docker rm -f $(IMAGE); fi
