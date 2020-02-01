#!/bin/sh
docker build . -t mushop-fulfillment:latest
echo
echo
echo "To run the docker container execute:"
echo "    $ docker run -p 8099:8099 mushop-fulfillment:latest"
