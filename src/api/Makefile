#!make

#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0
#

IMAGE=mushop-dev-api
CONTAINER=api
PROJECT=mutest

include $(wildcard .env)

.PHONY: test coverage

up: image server

down: kill-server kill-services

dev: clean image server

# Installs Node.js project dependencies
deps:
	@docker run               \
		-it                     \
		--rm                    \
		-v $$PWD:/usr/src/app   \
		$(IMAGE) /usr/local/bin/npm install

# Runs the Node.js application in a Docker container
server: kill-server 
	@docker run               \
		-d                      \
		--rm										\
		--name $(CONTAINER)     \
		--network-alias $(CONTAINER) \
		-v $$PWD:/usr/src/app   \
		-P                      \
		-e STATIC_MEDIA_URL=$(STATIC_MEDIA_URL) \
		-e CATALOGUE_URL=http://catalogue \
		-e CARTS_URL=http://carts \
		-e ORDERS_URL=http://orders \
		-e USERS_URL=http://user \
		-e EVENTS_URL=http://events \
		-e MOCK_MODE=$(MOCK_MODE) \
		-e NODE_ENV=development \
		-e PORT=3000            \
		-p 8080:3000            \
		-p 9229:9229            \
		--network mutest_default  \
		$(IMAGE) supper --inspect -i node_modules server.js

# Runs the Node.js application in a Docker container
mock: kill-server 
	@docker run               \
		-d                      \
		--rm										\
		--name $(CONTAINER)     \
		--network-alias $(CONTAINER) \
		-v $$PWD:/usr/src/app   \
		-P                      \
		-e STATIC_MEDIA_URL=$(STATIC_MEDIA_URL) \
		-e MOCK_MODE=all \
		-e NODE_ENV=development \
		-e PORT=3000            \
		-p 8080:3000            \
		-p 9229:9229            \
		$(IMAGE) supper --inspect -i node_modules server.js

# Removes the development container & image
clean:
	@if [ $$(docker ps -a -q -f name=$(IMAGE) | wc -l) -ge 1 ]; then docker rm -f $(IMAGE); fi
	@if [ $$(docker images -q $(IMAGE) | wc -l) -ge 1 ]; then docker rmi $(IMAGE); fi

# Builds the Docker image used for running tests
image:
	@docker build -t $(IMAGE) -f test/Dockerfile .

# Runs unit tests in Docker
test: image
	@docker run              \
		--rm                   \
		-it                    \
		-v $$PWD:/usr/src/app  \
		$(IMAGE) /usr/local/bin/npm test


kill-server:
	@if [ $$(docker ps -a -q -f name=$(CONTAINER) | wc -l) -ge 1 ]; then docker rm -f $$(docker ps -a -q -f name=$(CONTAINER)); fi

services:
	@docker-compose -p $(PROJECT) -f test/docker-compose.yml up -d
kill-services:
	@docker-compose -p $(PROJECT) -f test/docker-compose.yml down
