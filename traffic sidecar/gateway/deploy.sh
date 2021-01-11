cat <<EOF | kubectl apply -f -
# Log entry for egress access
apiVersion: "config.istio.io/v1alpha2"
kind: logentry
metadata:
  name: egress-access
  namespace: istio-system
spec:
  severity: '"info"'
  timestamp: request.time
  variables:
    destination: request.host | "unknown"
    path: request.path | "unknown"
    responseCode: response.code | 0
    responseSize: response.size | 0
    reporterUID: context.reporter.uid | "unknown"
    sourcePrincipal: source.principal | "unknown"
  monitored_resource_type: '"UNSPECIFIED"'
---
# Handler for error egress access entries
apiVersion: "config.istio.io/v1alpha2"
kind: stdio
metadata:
  name: egress-error-logger
  namespace: istio-system
spec:
 severity_levels:
   info: 2 # output log level as error
 outputAsJson: true
---
# Rule to handle access to *.cnn.com/politics
apiVersion: "config.istio.io/v1alpha2"
kind: rule
metadata:
  name: handle-politics
  namespace: istio-system
spec:
  match: request.host.endsWith("cnn.com") && request.path.startsWith("/politics") && context.reporter.uid.startsWith("kubernetes://istio-egressgateway")
  actions:
  - handler: egress-error-logger.stdio
    instances:
    - egress-access.logentry
---
# Handler for info egress access entries
apiVersion: "config.istio.io/v1alpha2"
kind: stdio
metadata:
  name: egress-access-logger
  namespace: istio-system
spec:
  severity_levels:
    info: 0 # output log level as info
  outputAsJson: true
---
# Rule to handle access to *.cnn.com
apiVersion: "config.istio.io/v1alpha2"
kind: rule
metadata:
  name: handle-cnn-access
  namespace: istio-system
spec:
  match: request.host.endsWith(".cnn.com") && context.reporter.uid.startsWith("kubernetes://istio-egressgateway")
  actions:
  - handler: egress-access-logger.stdio
    instances:
      - egress-access.logentry
EOF

