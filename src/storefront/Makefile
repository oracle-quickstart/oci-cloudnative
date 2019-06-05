IMAGE=mushop-dev-storefront

API=http://api:3000

up: services test-image start

down: kill-server kill-services

dev: clean test-image start

stop: kill-server

# Brings the backend services up using Docker Compose
services:
	@docker-compose -p mutest -f test/docker-compose.yml up -d

# Runs the application with browsersync in a Docker container
start:
	@docker run               \
		-it											\
		--rm										\
		--name $(IMAGE)     		\
		-v $$PWD:/usr/src/app   \
		-P                      \
		-e NODE_ENV=development \
		-e STATIC_ASSET_URL="https://objectstorage.us-phoenix-1.oraclecloud.com/n/intvravipati/b/mushop-images/o/" \
		-e API_PROXY=$(API) 		\
		-e PORT=3000            \
		-p 3000:3000            \
		--network mutest_default  \
		$(IMAGE) gulp

# Removes the development container
clean:
	@if [ $$(docker ps -a -q -f name=$(IMAGE) | wc -l) -ge 1 ]; then docker rm -f $(IMAGE); fi
	# @if [ $$(docker images -q $(IMAGE) | wc -l) -ge 1 ]; then docker rmi $(IMAGE); fi

# Builds the Docker image used for running tests
test-image:
	@docker build -t $(IMAGE) -f test/Dockerfile .

# Runs unit tests in Docker
# test: test-image
# 	@docker run              \
# 		--rm                   \
# 		-it                    \
# 		-v $$PWD:/usr/src/app  \
# 		$(IMAGE) /usr/local/bin/npm test

# Runs integration tests in Docker
# e2e: test-image
# 	@docker run              \
# 		--rm                   \
# 		-it                    \
# 		--network mutest_default \
# 		-v $$PWD:/usr/src/app  \
# 		$(IMAGE) /usr/src/app/test/e2e/runner.sh

kill-services:
	@docker-compose -p mutest -f test/docker-compose.yml down

stop-services:
	@docker-compose -p mutest -f test/docker-compose.yml stop

kill-server:
	@if [ $$(docker ps -a -q -f name=$(IMAGE) | wc -l) -ge 1 ]; then docker rm -f $(IMAGE); fi
