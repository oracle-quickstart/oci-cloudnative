FROM --platform=${TARGETPLATFORM:-linux/amd64} python:3.9

# Install locust
RUN pip install pyzmq locust faker

ADD locustfile.py /config/locustfile.py
ADD runLocust.sh /usr/local/bin/runLocust.sh

ENV LOCUST_FILE /config/locustfile.py

EXPOSE 8089

ENTRYPOINT ["/usr/local/bin/runLocust.sh"]
