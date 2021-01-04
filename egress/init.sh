# Install eksctl with Homebrew for macOS
brew install weaveworks/tap/eksctl

brew install helm

# Create EKS cluster with cluster name "istio-on-eks"
eksctl create cluster --name=istio-on-eks \
--node-type=t2.medium --nodes-min=2 --nodes-max=2 \
--region=us-east-1 --zones=us-east-1a,us-east-1b,us-east-1c,us-east-1d 

go get -u -v github.com/kubernetes-sigs/aws-iam-authenticator/cmd/aws-iam-authenticator

curl -L https://git.io/getLatestIstio | sh -

cd istio-

kubectl create -f ~/install/kubernetes/helm/helm-service-account.yaml
helm init --service-account tiller

helm install \
--wait \
--name istio-init \
--namespace istio-system \
install/kubernetes/helm/istio-init

helm install \
--wait \
--name istio \
--namespace istio-system \
install/kubernetes/helm/istio \
--values install/kubernetes/helm/istio/values-istio-demo.yaml

kubectl label namespace default istio-injection=enabled