# Contour development deployment

This deployment assumes that the user is working with a [kind
cluster](https://kind.sigs.k8s.io/docs/user/ingress) and a development
version of Contour.

- No TLS certificates are generated or deployed for the xDS session
- No Contour pods are run inside the cluster

Once the YAML has been applied, you need to edit the Envoy DaemonSet to
set the `--xds-server` flag for `contour bootstrap` to the IP address of
the system where you are running kind:

```
$ kubectl --context kind-contour --namespace projectcontour edit daemonset envoy
```

Next, run a local Contour build:

```
$ contour serve --insecure --xds-address=0.0.0.0 --envoy-service-http-port=80 --envoy-service-https-port=443
```

Unlike a typical Contour deployment, where a `contour bootstrap` init
container generates the Envoy bootstrap configuration, this is generated
locally and passed to the Envoy DaemonSet in a ConfigMap. This allows
us to inject the local host IP address as the xDS server address so that
Envoy will automatically connect to a locally running Contour.
