# Deploy Knative Serving + Contour

This kustomization deploys Knative Serving with Contour as a default
Ingress implementation.

## Overview

We deploy a standard Knative Serving version from the [base](../../base).
to this, we add the [net-contour](https://github.com/mattmoor/net-contour)
controller that implements the "contour.ingress.networking.knative.dev"
Ingress class.

There are two separate Contour deployments in the "projectcontour-internal"
and "projectcontour-internal" namespaces. Since each deployment
needs a separate pool of Envoy proxies (which are deployed as a
DaemonSet), each DaemonSet restricts itself to labeled nodes. As a
separate manual step, you need to apply the
"projectcontour.io/envoy-pool=internal" or
projectcontour.io/envoy-pool=external" labels to the
nodes that should get an Envoy proxy pod.

## Building

The [makefile](GNUmakefile) is used to build the deployment YAML,
due to some kustomize limitations. `make yaml` will run kustomize
to generate YAML to the `out` directory by default (you can change
this by setting the `DESTDIR` make variable.)

