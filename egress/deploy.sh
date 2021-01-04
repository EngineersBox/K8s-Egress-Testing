export IAMGE_NAME="Image name here"

brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
brew install kubernetes-cli
brew install helm

kubectl create namespace istio-system

export USERNAME=$(echo -n 'admin' | base64)
export PASSPHRASE=$(echo -n 'supersecretpassword!!' | base64)
export NAMESPACE=istio-system

echo "---- Creating Kubernetes Pod ----"
cat <<EOF | kubectl apply -n istio-system -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: $NAMESPACE
  labels:
    app: kiali
type: Opaque
data:
  username: $USERNAME
  passphrase: $PASSPHRASE
EOF
echo "---------------------------------"

helm template istio-1.1.4/install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -  

# Check the created Istio CRDs 
export ISTIO_CRDS=kubectl get crds -n istio-system | grep 'istio.io\|certmanager.k8s.io' | wc -l
echo "\n---- Istio CRDs ----"
echo $ISTIO_CRDS
echo "--------------------"

helm template istio-1.1.4/install/kubernetes/helm/istio\
    --name istio\
    --namespace istio-system\
    --set grafana.enabled=true\
    --set tracing.enabled=true\
    --set kiali.enabled=true\
    --set kiali.dashboard.secretName=kiali\
    --set kiali.dashboard.usernameKey=username\
    --set kiali.dashboard.passphraseKey=passphrase | kubectl apply -f -
 
# Validate and see that all components start
kubectl get pods -n istio-system -w

kubectl patch svc kiali -n istio-system --patch '{"spec": {"type": "LoadBalancer" }}'

# Get the create AWS ELB for the Kiali service
export KIALI_AWS_ELB=kubectl get svc kiali -n istio-system --no-headers | awk '{ print $4 }'
echo "\n---- Kiali AWS ELB ----"
echo $KIALI_AWS_ELB
echo "-----------------------"

# Label default namespace to inject Envoy sidecar
kubectl label namespace default istio-injection=enabled

# Check istio sidecar injector label
kubectl get namespace -L istio-injection

# Deploy Google hipster shop manifests
kubectl create -f https://raw.githubusercontent.com/berndonline/aws-eks-terraform/master/example/istio-hipster-shop.yml
kubectl create -f https://raw.githubusercontent.com/berndonline/aws-eks-terraform/master/example/istio-manifest.yml

# Wait a few minutes before deploying the load generator
sleep 300
kubectl create -f https://raw.githubusercontent.com/berndonline/aws-eks-terraform/master/example/istio-loadgenerator.yml

export INGRESS_GATEWAY_HOSTNAME=kubectl get svc istio-ingressgateway -n istio-system --no-headers | awk '{ print $4 }'
echo "\n---- Ingress Gateway Hostname ----"
echo $INGRESS_GATEWAY_HOSTNAME
echo "----------------------------------"