# CFSSL image 

A Dockerfile to provision the newest
[cfssl](https://github.com/cloudflare/cfssl). Suitable for running as
a PKI component in dev environments.

Support OCSP. No stapling.

Mount your cert volume at `/cfssl`.

## Generating the CA

There is a self-signed root CA which is used for all resources and for revocations.

``` shellsession
% cd rootca
% cfssl gencert -initca csr.json | cfssljson -bare rootca
```

will generate `rootca-key.pem`, `rootca.pem`, and `rootca.csr` (for cross-signing).

Policies are defined in `rootca/config.json` for *server*, *peer*, and *client* roles. The authentication key can be generated with `openssl rand -hex 16` and set in `CFSSL_API_KEY`. 

## OCSP

Install goose and create a SQLite database using the cfssl source.

``` shellsession
% go get bitbucket.org/liamstask/goose/cmd/goose
% goose -path certdb/sqlite -env production up
```

A `certstore_production.db` file will be created in the current dir. This file is to be referenced in `db.json`. The `config.json` would have `oscp_url` and `crl_url`. An example of each file is provided.

## Generating an intemediate CA

``` shellsession
% cd sshca
# Generate pair
% cfssl genkey -initca csr.json | cfssljson -bare ssh
# Sign cert with root CA
% cfssl sign -ca=../rootca/rootca.pem -ca-key=../rootca/rootca-key.pem -config=config.json -profile peer ssh.csr | cfssljson -bare ssh
```

## Generating an mTLS pair
### Server

``` shellsession
% cd int-service-server
% cfssl gencert -ca=../rootca/rootca.pem -ca-key=../rootca/rootca-key.pem -config=../rootca/config.json -profile=server csr.json | cfssljson -bare server
2020/07/15 13:20:52 [INFO] generate received request
2020/07/15 13:20:52 [INFO] received CSR
2020/07/15 13:20:52 [INFO] generating key: rsa-2048
2020/07/15 13:20:52 [INFO] encoded CSR
2020/07/15 13:20:52 [INFO] signed certificate with serial number 663159741018569081174195573531782268524107605227
```

### Client

``` shellsession
% cd int-service-server
% cfssl gencert -ca=../rootca/rootca.pem -ca-key=../rootca/rootca-key.pem -config=../rootca/config.json -profile=client csr.json | cfssljson -bare client
2020/07/15 13:24:57 [INFO] generate received request
2020/07/15 13:24:57 [INFO] received CSR
2020/07/15 13:24:57 [INFO] generating key: rsa-2048
2020/07/15 13:24:57 [INFO] encoded CSR
2020/07/15 13:24:57 [INFO] signed certificate with serial number 725072888192259310810651287891602680708173053814
```

# What's not checked in

- keys
- certs

# What's checked in

- CSR definitions in JSON form
- policies
