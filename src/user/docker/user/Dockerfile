FROM golang:1.7-alpine

COPY . /go/src/github.com/junior/mushop/src/user/
WORKDIR /go/src/github.com/junior/mushop/src/user/

RUN apk update
RUN apk add git
RUN go get -v github.com/Masterminds/glide 
RUN glide install && CGO_ENABLED=0 go build -a -installsuffix cgo -o /user main.go

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
COPY --from=0 /user /

RUN	chmod +x /user && \
	chown -R ${SERVICE_USER}:${SERVICE_GROUP} /user && \
	setcap 'cap_net_bind_service=+ep' /user

USER ${SERVICE_USER}

CMD ["/user", "-port=80"]
