#!/bin/bash

kubectl create -f backend-deployment.yaml --namespace development
kubectl create -f frontend-deployment.yaml --namespace development

kubectl get deployment --namespace development
kubectl get pods --namespace development
kubectl get rs --namespace development

kubectl create -f backend-service.yaml --namespace development
kubectl create -f frontend-service.yaml --namespace development

kubectl get svc --namespace development

kubectl describe service/frontend-svc --namespace development

minikube service frontend-svc -n development