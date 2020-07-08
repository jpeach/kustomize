#! /usr/bin/env bash

# contour-multiple-tls-services.sh: Spin up multiple TLS services in Contour.

set -o errexit
set -o pipefail
set -o nounset

readonly PROGNAME=$(basename $0)

readonly KUBECTL=${KUBECTL:-kubectl}

readonly NAMESPACE=$(echo ${NAMESPACE:-${PROGNAME}} | tr -c -d 'a-zA-Z0-9-')

usage() {
    echo "usage: $PROGNAME [END] | $PROGNAME [START] [END]"
    exit 64 # EX_USAGE
}

case $# in
0) INTERACTIVE=Y ;;
1) END="$1";;
2) START="$1" ; END="$2";;
*) usage;;
esac

readonly START=${START:-"0"}
readonly END=${END:-"1000000"}
readonly INTERACTIVE=${INTERACTIVE:-"N"}

${KUBECTL} create namespace "${NAMESPACE}" || true

echo Create deployment
${KUBECTL} apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: &name ingress-conformance-echo
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: *name
  template:
    metadata:
      labels:
        app.kubernetes.io/name: *name
    spec:
      containers:
      - name: conformance-echo
        image: agervais/ingress-conformance-echo:latest
        env:
        - name: TEST_ID
          value: *name
        ports:
        - name: http-api
          containerPort: 3000
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
EOF

echo Create service
${KUBECTL} apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: &name ingress-conformance-echo
  namespace: $NAMESPACE
spec:
  ports:
  - name: http
    port: 80
    targetPort: http-api
  selector:
    app.kubernetes.io/name: *name
EOF

# Create a self-signed issuer to give us secrets.
${KUBECTL} apply -f - <<EOF
apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  name: selfsigned
  namespace: $NAMESPACE
spec:
  selfSigned: {}
EOF

COUNT=$START
while (( $COUNT <= $END )) ; do

    case ${INTERACTIVE} in
    N|n) ;;
    *) read -p "Apply proxy #${COUNT}? " ;;
    esac

    # Issue a certificate.
    ${KUBECTL} apply -f - <<EOF
    apiVersion: cert-manager.io/v1alpha2
    kind: Certificate
    metadata:
      name: conformance-echo-${COUNT}
      namespace: $NAMESPACE
    spec:
      dnsNames:
      - "echo-${COUNT}.projectcontour.io"
      secretName: conformance-echo-${COUNT}
      issuerRef:
        name: selfsigned
EOF

    # Wait for the certificate before we use the secret if generates.
    ${KUBECTL} wait --timeout=5m -n ${NAMESPACE} certificate conformance-echo-${COUNT} --for=condition=Ready

    ${KUBECTL} apply -f - <<EOF
    apiVersion: projectcontour.io/v1
    kind: HTTPProxy
    metadata:
      name: echo-${COUNT}
      namespace: $NAMESPACE
    spec:
      virtualhost:
        fqdn: echo-${COUNT}.projectcontour.io
        tls:
          secretName: conformance-echo-${COUNT}
      routes:
      - services:
        - name: ingress-conformance-echo
          port: 80
EOF

    COUNT=$(($COUNT + 1))
done
