#! /usr/bin/env bash

# kind-dev-cluster.sh: spin up a Contour dev configuration in Kind

set -o errexit
set -o pipefail

readonly PROGNAME=$(basename $0)
readonly KIND=${KIND:-kind}
readonly KUBECTL=${KUBECTL:-kubectl}

readonly HERE=$(cd $(dirname $0) && pwd)
readonly REPO=$(cd ${HERE}/.. && pwd)

usage() {
    echo usage: $PROGNAME [CLUSTERNAME]
    exit 64 # EX_USAGE
}

case $# in
0) ;;
1) CLUSTER="$1";;
*) usage;;
esac

readonly CLUSTER=${CLUSTER:-contour}

kind::cluster::list() {
    ${KIND} get clusters
}

# Emit a Kind config that maps the envoy listener ports to the host.
kind::cluster::config() {
    cat <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    listenAddress: "0.0.0.0"
  - containerPort: 443
    hostPort: 443
    listenAddress: "0.0.0.0"
EOF
}

kind::cluster::create() {
    ${KIND} create cluster \
        --config <(kind::cluster::config) \
        --name ${CLUSTER}
}

if kind::cluster::list | grep -q "^$CLUSTER$" ; then
	echo Cluster \"$CLUSTER\" already exists
	exit 0
fi

kind::cluster::create

cat <<EOF

Deploy Contour to cluster "$CLUSTER":

make -C $REPO/contour/configurations/kind-devel apply.kubectl

Run Contour locally:

contour serve --insecure --xds-address=0.0.0.0 --envoy-service-http-port=80 --envoy-service-https-port=443

EOF
