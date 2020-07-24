FROM golang:latest AS builder

LABEL version="1.0"

ENV GOPATH "/go"
RUN CGO_ENABLED=0 go get -u github.com/cloudflare/cfssl/cmd/...

FROM alpine:latest
COPY --from=builder /go/bin/* /usr/local/bin/
ENV PATH "${PATH}:/usr/local/bin"

EXPOSE 8888
VOLUME /cfssl
WORKDIR /cfssl

ENTRYPOINT [ "cfssl", "serve", "-address=0.0.0.0" ]
CMD [ "-port=8888", "-ca=rootca/rootca.pem", "-ca-key=rootca/rootca-key.pem", "-config=rootca/config.json", "-loglevel", "1" ]
