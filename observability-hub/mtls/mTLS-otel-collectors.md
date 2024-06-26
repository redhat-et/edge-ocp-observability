## Set up mTLS between OpenShift OTC (server) and Edge OTC (client)

This document borrows heavily from [Roberto Carratalá's excellent post](https://rcarrata.com/openshift/mtls-ingress-controller/).
Roberto's post has additional explanations for the steps below.

OTC will run at the edge with a podman command. For this example, a self-signed certificate for `localhost`
is created at the edge. Traffic will be secured from edge OTC to OpenShift hub OTC by sharing CAs, certificates, and private keys.

This assumes you are in mtls directory of this repository:

```bash
mkdir demoCA
mkdir demoCA/certs demoCA/newcerts demoCA/private
```

Create an index.txt and serial file to track certificates signed by the CA certificate.

```bash
echo 1000 > demoCA/serial
touch demoCA/index.txt
```

### Create CA (on edge/client machine)

This CA will be shared as a configmap in OpenShift.
Then the configmap will be mounted within the OTC pod.

First, create a private key for the CA certificate.

```bash
openssl genrsa -out demoCA/private/cakey.pem 4096
```

Set the Common Name for the CA certificate.
I am using `localhost` here, maybe replace with `$(hostname)` if desired
Then, create the CA certificate.
Lastly, convert the CA cert to PEM format.

```bash
SUBJ_EDGE="/CN=localhost/ST=NY/C=US/O=None/OU=None"
openssl req -new -subj ${SUBJ_EDGE} -x509 -days 3650 -config openssl.cnf -key demoCA/private/cakey.pem -out demoCA/certs/cacert.pem
openssl x509 -in demoCA/certs/cacert.pem -out demoCA/certs/cacert.pem -outform PEM
```

Verify the CA certificate was  generated with openssl:

```bash
openssl x509 -in demoCA/certs/cacert.pem -text -noout
```

The CA can now be shared with OpenShift as a configmap to be mounted in the hub OTC:

```bash
oc create configmap -n observability clientca --from-file demoCA/certs/cacert.pem
```

### Create the Server certificate (using OpenShift OTC route hostname & the new CA)

Generate a private key for the server certificate:

```bash
openssl genrsa -out demoCA/private/server.key.pem 4096
```

Extract OpenShift base domain:

```
APPS_DOMAIN="apps.$(oc get dns cluster -o jsonpath='{ .spec.baseDomain }')"
```

Generate a CSR and server certificate for the OTC route.
Note in the example OTC manifests, the OTC route hostname is
`otc.${APPS_DOMAIN}`. Therefor, the CN is `otc.${APPS_DOMAIN}`. Also, note that
there is a limit of 64 character length for CN. The OTC route hostname must match the CN below.

```bash
openssl req -new -key demoCA/private/server.key.pem -out server-csr.pem -subj "/CN=otc.${APPS_DOMAIN}"
openssl x509 -req -extfile <(printf "subjectAltName=DNS:otc.${APPS_DOMAIN}") -in server-csr.pem -CA demoCA/certs/cacert.pem -CAkey demoCA/private/cakey.pem -CAcreateserial -out demoCA/certs/server.cert.pem -days 365 -sha256
```

Create a configmap in OpenShift observability namespace to share the server certificate and private key:

```bash
oc create configmap tls-otelcol --from-file demoCA/certs/server.cert.pem --from-file demoCA/private/server.key.pem -n observability
```

The `clientca` configmap and the `tls-otelcol` configmap are mounted in the OpenShift OTC. These are
specified in the [otel-collector manifests](../otel-collector/kustomization.yaml).

### Create the Client certificate

First, create private key for the client certificate.

```bash
openssl genrsa -out demoCA/private/client.key.pem 4096
```

Generate Certificate Signing Request (CSR) for the client certificate.
We will use the matching `$SUBJ_EDGE` that we used to create the CA cert above.

```bash
openssl req -new -subj ${SUBJ_EDGE} -key demoCA/private/client.key.pem -out demoCA/certs/client.csr
```

Add certificate extensions. Create an additional configuration file with the required extensions:

```bash
cat <<EOF > client_ext.cnf
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection
EOF
```

Finally, create the client certificate.

```bash
openssl ca -config openssl.cnf -extfile client_ext.cnf -days 3650 -notext -batch -in demoCA/certs/client.csr -out demoCA/newcerts/client.cert.pem
chmod 400 demoCA/newcerts/client.cert.pem

# The index.txt will be updated reflecting the generated certificate:
cat demoCA/index.txt
V       311109225709Z           02      unknown /C=US/ST=NY/O=None/OU=None/CN=localhost

# The CSR can now be removed
rm -rf demoCA/certs/client.csr
```
