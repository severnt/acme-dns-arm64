FROM golang:alpine AS builder

RUN apk add --update gcc musl-dev

WORKDIR /go/src

ENV GOPATH /go

COPY acme-dns /go/src/acme-dns

RUN cd /go/src/acme-dns && CGO_ENABLED=1 go build

FROM alpine:latest

WORKDIR /

RUN mkdir -p /etc/acme-dns &&\
  mkdir -p /var/lib/acme-dns &&\
  apk --no-cache add ca-certificates && update-ca-certificates

COPY --from=builder /go/src/acme-dns/acme-dns .

VOLUME ["/etc/acme-dns", "/var/lib/acme-dns"]
ENTRYPOINT ["/acme-dns"]
EXPOSE 53 80 443
EXPOSE 53/udp
