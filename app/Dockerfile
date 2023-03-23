## Build
FROM golang:1.20-alpine AS build

WORKDIR /app
COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./
RUN go build -o /foobar-api

## Deploy
FROM alpine:3.9

WORKDIR /
RUN apk add ca-certificates
COPY --from=build /foobar-api /app

EXPOSE 80
ENTRYPOINT ["/app"]