echo "---- Deleting Labeled Kubernetes Components ----"
kubectl label namespace default istio-injection-
kubectl delete -f https://raw.githubusercontent.com/berndonline/aws-eks-terraform/master/example/istio-loadgenerator.yml
kubectl delete -f https://raw.githubusercontent.com/berndonline/aws-eks-terraform/master/example/istio-hipster-shop.yml
kubectl delete -f https://raw.githubusercontent.com/berndonline/aws-eks-terraform/master/example/istio-manifest.yml
echo "------------------------------------------------"

echo "\n---- Removing Istio From EKS ----"
helm template istio-1.1.4/install/kubernetes/helm/istio\
    --name istio\
    --namespace istio-system\
    --set grafana.enabled=true\
    --set tracing.enabled=true\
    --set kiali.enabled=true\
    --set kiali.dashboard.secretName=kiali\
    --set kiali.dashboard.usernameKey=username\
    --set kiali.dashboard.passphraseKey=passphrase | kubectl delete -f -
echo "---------------------------------"