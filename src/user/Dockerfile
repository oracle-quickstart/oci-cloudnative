FROM golang:1.12-alpine AS go-builder
RUN apk add --no-cache ca-certificates git
WORKDIR /src
COPY . .

RUN GO111MODULE=on GOARCH=amd64 CGO_ENABLED=0 GOOS=linux \
	go build -a \
	-installsuffix cgo \
	-o /user main.go

FROM alpine:3.4
ENV	SERVICE_USER=myuser \
	SERVICE_UID=10001 \
	SERVICE_GROUP=mygroup \
	SERVICE_GID=10001

RUN	addgroup -g ${SERVICE_GID} ${SERVICE_GROUP} && \
	adduser -g "${SERVICE_NAME} user" -D -H -G ${SERVICE_GROUP} -s /sbin/nologin -u ${SERVICE_UID} ${SERVICE_USER} && \
	apk add --update libcap

ENV HATEAOS user
ENV USER_DATABASE mongodb
ENV MONGO_HOST user-db

WORKDIR /
EXPOSE 80
COPY --from=go-builder /user /

RUN	chmod +x /user && \
	chown -R ${SERVICE_USER}:${SERVICE_GROUP} /user && \
	setcap 'cap_net_bind_service=+ep' /user

USER ${SERVICE_USER}

CMD ["/user", "-port=80"]
