#!/bin/bash

# Create a directory to store certificates
CERT_DIR="demoCA"
rm -rf "$CERT_DIR"
mkdir -p "$CERT_DIR"

# Get hostname domain from OpenShift
hostname_domain="*.apps.$(oc get dns cluster -o jsonpath='{.spec.baseDomain}')"

# Set certificate information
CERT_SUBJECT="/C=US/ST=California/L=San Francisco/O=My Organization/CN=opentelemetry"

# Create a temporary OpenSSL configuration file for SANs
openssl_config="$CERT_DIR/openssl.cnf"
cat <<EOF > "$openssl_config"
[req]
req_extensions = v3_req

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = opentelemetry
DNS.2 = $hostname_domain
EOF

# Generate private key for the server
openssl genpkey -algorithm RSA -out "$CERT_DIR/server.key"

# Create CSR for the server with SANs
openssl req -new -key "$CERT_DIR/server.key" -out "$CERT_DIR/server.csr" -subj "$CERT_SUBJECT" -config "$openssl_config"

# Generate self-signed certificate for the server with SANs
openssl x509 -req -days 365 -in "$CERT_DIR/server.csr" -signkey "$CERT_DIR/server.key" -out "$CERT_DIR/server.crt" -extensions v3_req -extfile "$openssl_config"

# Generate a CA certificate (self-signed)
openssl req -new -x509 -days 365 -key "$CERT_DIR/server.key" -out "$CERT_DIR/ca.crt" -subj "$CERT_SUBJECT"

echo "Certificates generated successfully in $CERT_DIR directory."

# Delete any existing ConfigMaps
oc delete secret -n observability mtls-certs

# Create a Kubernetes Secret for the server certificate, private key, and CA certificate in observability namespace
oc create secret generic mtls-certs -n observability \
  --from-file=server.crt="$CERT_DIR/server.crt" \
  --from-file=server.key="$CERT_DIR/server.key" \
  --from-file=ca.crt="$CERT_DIR/ca.crt"

echo "mtls-certs secret created successfully."
