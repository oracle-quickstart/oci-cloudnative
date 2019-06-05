FROM alpine:3.4

ENV	SERVICE_USER=myuser \
	SERVICE_UID=10001 \
	SERVICE_GROUP=mygroup \
	SERVICE_GID=10001

RUN	addgroup -g ${SERVICE_GID} ${SERVICE_GROUP} && \
	adduser -g "${SERVICE_NAME} user" -D -H -G ${SERVICE_GROUP} -s /sbin/nologin -u ${SERVICE_UID} ${SERVICE_USER} && \
	apk add --update libcap

WORKDIR /
EXPOSE 80
COPY app /

RUN	chmod +x /app && \
	chown -R ${SERVICE_USER}:${SERVICE_GROUP} /app && \
	setcap 'cap_net_bind_service=+ep' /app

USER ${SERVICE_USER}

CMD ["/app", "-port=80"]
