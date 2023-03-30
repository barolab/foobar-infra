## Build
FROM golang:1.20-alpine AS build

WORKDIR /app
COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./
RUN go build -o /foobar-api

## Deploy
FROM alpine:3.17

WORKDIR /
COPY --from=build /foobar-api /app
ENV UID=65532
ENV GID=65532
RUN apk add libcap=2.66-r0 ca-certificates=20220614-r4 --update --no-cache &&  \
    rm -rf /var/cache/apk/* && \
    addgroup --gid 65532 app && \
    adduser --disabled-password --gecos "" --home / --ingroup app --no-create-home --uid 65532 app && \
    chown app:app /app && \
    chmod +x /app && \
    setcap CAP_NET_BIND_SERVICE=+eip /app

USER app
EXPOSE 80
ENTRYPOINT ["/app"]
