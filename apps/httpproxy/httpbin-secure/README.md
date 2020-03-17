# Deploy HTTPBin with HTTPS

1. Install cert-manager using the [base](../../../cert-manager/base/)
   kustomization. This will create a self-signed issuer in the default
   namespace, which will be used here.

2. Deploy httpbin using kustomize, i.e. `kustomize build . | kubectl appl -f -`.

4. Verify the proxies are valid:

```
$ kubectl get proxies
NAME       FQDN                  TLS SECRET   STATUS   STATUS DESCRIPTION
httpbin    httpbin.jpeach.org    httpbin      valid    valid HTTPProxy
httpbin2   httpbin2.jpeach.org   httpbin      valid    valid HTTPProxy
```

3. Test it out. You will need a non-ancient version of curl that supports
   the [resolve](https://curl.haxx.se/docs/manpage.html#--resolve) flag.

   If the IP address of your external load balancer is `1.2.3.4`, then:

```
$ curl -k --resolve *:443:34.87.241.252 https://httpbin.jpeach.org/get
```
