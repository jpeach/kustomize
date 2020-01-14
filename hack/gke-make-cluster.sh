#! /usr/bin/env bash

set -o errexit
set -o pipefail

readonly PROGNAME=$(basename $0)

GCLOUD=${GCLOUD:-gcloud}

usage() {
    echo usage: $PROGNAME [CLUSTERNAME]
    exit 64 # EX_USAGE
}

case $# in
0) ;;
1) GKE_CLUSTER="$1";;
*) usage;;
esac


readonly GKE_PROJECT=${GKE_PROJECT:-$(gcloud config get-value core/project)}
readonly GKE_ZONE=${GKE_ZONE:-$(gcloud config get-value compute/zone)}
readonly GKE_REGION=${GKE_REGION:-$(gcloud config get-value compute/region)}

readonly GKE_CLUSTER=${GKE_CLUSTER:="knative-dev-1"}
readonly GKE_MACHINE_TYPE=${GKE_MACHINE_TYPE:-"n1-standard-2"}
readonly GKE_NUM_NODES=${GKE_NUM_NODES:-"4"}

$GCLOUD \
    beta container clusters create ${GKE_CLUSTER} \
    --project ${GKE_PROJECT} \
    --zone ${GKE_ZONE} \
    --no-enable-basic-auth \
    --release-channel "rapid" \
    --machine-type ${GKE_MACHINE_TYPE} \
    --image-type "COS" \
    --disk-type "pd-standard" \
    --disk-size "100" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --num-nodes ${GKE_NUM_NODES} \
    --enable-stackdriver-kubernetes \
    --enable-ip-alias \
    --network "projects/${GKE_PROJECT}/global/networks/default" \
    --subnetwork "projects/${GKE_PROJECT}/regions/${GKE_REGION}/subnetworks/default" \
    --default-max-pods-per-node "110" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing \
    --enable-autoupgrade \
    --enable-autorepair

$GCLOUD container clusters get-credentials $GKE_CLUSTER

echo kubectl context is "gke_${GKE_PROJECT}_${GKE_ZONE}_${GKE_CLUSTER}"
kubectl cluster-info --context "gke_${GKE_PROJECT}_${GKE_ZONE}_${GKE_CLUSTER}"
