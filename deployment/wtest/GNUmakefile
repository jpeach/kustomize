SHELL := bash

DIRS := $(shell pwd)/acme/conf $(shell pwd)/acme/tmp $(shell pwd)/acme/log

# First, install all the YAML. Probably need to run more than once since
# kubectl doesn't update its APIs after installing CRDs.
install:
	if ! kubectl get clusterrolebinding cluster-admin-binding >/dev/null 2>&1 ; then\
		kubectl create clusterrolebinding cluster-admin-binding \
		    --clusterrole=cluster-admin \
		    --user=$$(gcloud config get-value core/account); \
	fi
	kubectl apply -f <(kustomize build .)

# Run this once to generate the wildcard certificate. Needs the manual
# DNS01 challenge.
certificates: $(DIRS)
	certbot certonly \
		--config-dir $$(pwd)/acme/conf \
		--work-dir $$(pwd)/acme/tmp \
		--logs-dir $$(pwd)/acme/log \
		--manual \
		-d '*.wtest.jpeach.org'

# Once the certificates are there, install symlinks for kustomize secrets
# generator.
links:
	ln -sf acme/conf/live/wtest.jpeach.org/cert.pem tls.crt
	ln -sf acme/conf/live/wtest.jpeach.org/privkey.pem tls.key
	ln -sf acme/conf/live/wtest.jpeach.org/chain.pem ca.crt

$(DIRS):
	mkdir -p $@
