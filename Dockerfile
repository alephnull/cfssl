FROM golang:latest AS builder

LABEL version="1.3"

ENV GOPATH "/go"
RUN go get -u github.com/cloudflare/cfssl/cmd/...

FROM debian:buster-slim
RUN apt-get update && apt-get dist-upgrade -y libsqlite3-0
COPY --from=builder /go/bin/* /usr/local/bin/
#ENV PATH "${PATH}:/usr/local/bin"

EXPOSE 8888
VOLUME /cfssl
WORKDIR /cfssl

ENTRYPOINT [ "/usr/local/bin/cfssl", "serve", "-address=0.0.0.0" ]
CMD [ "-port=8888", '-db-config=db.json', "-ca=rootca/rootca.pem", "-ca-key=rootca/rootca-key.pem", "-config=config.json", "-loglevel", "1" ]
