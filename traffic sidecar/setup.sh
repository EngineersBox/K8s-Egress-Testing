#!/bin/bash

# Install relevant tooling
brew instal kubectl minikube istioctl

# Start up test cluster
minikube start
# Create test web app instance
kubectl apply -f example.yaml

# ---- ISTIO INSTALL AND CONFIG ---- #

#istioctl install
#istioctl install --set meshConfig.accessLogFile=/dev/stdout

# Clone down the dns-dicovery module
git clone https://github.com/istio-ecosystem/dns-discovery

cd dns-discovery
# Deploy the dns-discovery module
make install
cd -
