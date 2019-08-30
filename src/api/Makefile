IMAGE=mushop-dev-api
CONTAINER=api

.PHONY: test coverage

up: compose test-image server

down: kill-server kill-compose

dev: clean test-image server

# Brings the backend services up using Docker Compose
compose:
	@docker-compose -p mutest -f test/docker-compose.yml up -d

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
		-e NODE_ENV=development \
		-e CATALOGUE_URL=http://catalogue \
		-e CARTS_URL=http://carts \
		-e ORDERS_URL=http://orders \
		-e USERS_URL=http://user \
		-e PORT=3000            \
		-p 8080:3000            \
		-p 9229:9229            \
		--network mutest_default  \
		$(IMAGE) supper --inspect -i node_modules server.js

mock: kill-server 
	@docker run               \
		-d                      \
		--rm										\
		--name $(CONTAINER)     \
		--network-alias $(CONTAINER) \
		-v $$PWD:/usr/src/app   \
		-P                      \
		-e MOCK_MODE=all				\
		-e NODE_ENV=development \
		-e PORT=3000            \
		-p 8080:3000            \
		-p 9229:9229            \
		--network mutest_default  \
		$(IMAGE) supper --inspect -i node_modules server.js

# Removes the development container & image
clean:
	@if [ $$(docker ps -a -q -f name=$(IMAGE) | wc -l) -ge 1 ]; then docker rm -f $(IMAGE); fi
	@if [ $$(docker images -q $(IMAGE) | wc -l) -ge 1 ]; then docker rmi $(IMAGE); fi

# Builds the Docker image used for running tests
test-image:
	@docker build -t $(IMAGE) -f test/Dockerfile .

# Runs unit tests in Docker
test: test-image
	@docker run              \
		--rm                   \
		-it                    \
		-v $$PWD:/usr/src/app  \
		$(IMAGE) /usr/local/bin/npm test

# Runs integration tests in Docker
e2e: test-image
	@docker run              \
		--rm                   \
		-it                    \
		--network mutest_default \
		-v $$PWD:/usr/src/app  \
		$(IMAGE) /usr/src/app/test/e2e/runner.sh

kill-compose:
	@docker-compose -p mutest -f test/docker-compose.yml down

kill-server:
	@if [ $$(docker ps -a -q -f name=$(CONTAINER) | wc -l) -ge 1 ]; then docker rm -f $(CONTAINER); fi
