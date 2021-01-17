# Egress Capturing

An article on deploying and configuring istio for network traffic capturing

#### 1. Config (`istio_config.yaml`):

Setup istio with the following config, to allow for:

* Viewing the logs of an envoy proxy sidecar instance from `kubectl logs`
* An ingress gateway to apply rules to for global traffic
* An egres gateway to apply rules to for global trafic

```yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: default
  hub: quay.io/instaclustr
  tag: latest
  revision: 1-8-0
  namespace: instaclustr-istio
  meshConfig:
    accessLogFile: /dev/stdout
    enableTracing: true
  components:
    egressGateways:
    - name: base-egressgateway
      enabled: true
    ingressGateways:
    - name: base-ingressgateway
      enabled: true
```

#### 2. Apply config to cluster

```bash
istioct install -f istio_config.yaml
```

#### 3. Deploy apps

Here we will use two example apps:

* Sleep
* Httpbin

Deploy both apps with:

```bash
kubectl apply -f <(istioctl kube-inject -f sleep/sleep.yaml)
kubectl apply -f <(istioctl kube-inject -f httpbin/httpbin.yaml)
```

#### 4. Storing sleep app name

Store the ID of the sleep app with:

```bash
export SOURCE_POD=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})
```

#### 5. Test request

Invoke a request to the httpbin app from the sleep app:

```bash
kubectl exec "$SOURCE_POD" -c sleep -- curl -v httpbin:8000/status/418
```

Which should result in something like:

```text
...
< HTTP/1.1 418 Unknown
< server: envoy
...
    -=[ teapot ]=-

       _...._
     .'  _ _ `.
    | ."` ^ `". _,
    \_;`"---"`|//
      |       ;/
      \_     _/
        `"""`
```

#### 6. View traffic logs

To view the traffic logs, we use the `kubectl logs` command and specify the app and the proxy

Get sleep app logs:

```bash
kubectl logs -l app=sleep -c istio-proxy
```

Logs:

```log
[2020-01-17T12:36:44.547Z] "GET /status/418 HTTP/1.1" 418 - "-" 0 135 25 24 "-" "curl/7.69.1" "f13c2118-3ef9-9ed9-91b7-5d21358029c3" "httpbin:8000" "10.244.0.30:80" outbound|8000||httpbin.default.svc.cluster.local 10.244.0.29:46348 10.96.148.56:8000 10.244.0.29:44678 - default
```

Get httpbin app logs:

```bash
kubectl logs -l app=httpbin -c istio-proxy
```

Logs:

```log
[2020-01-17T12:36:44.553Z] "GET /status/418 HTTP/1.1" 418 - "-" 0 135 3 2 "-" "curl/7.69.1" "f13c2118-3ef9-9ed9-91b7-5d21358029c3" "httpbin:8000" "127.0.0.1:80" inbound|8000|| 127.0.0.1:42940 10.244.0.30:80 10.244.0.29:46348 outbound_.8000_._.httpbin.default.svc.cluster.local default
```
