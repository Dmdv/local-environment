#!/usr/bin/env bash

# Create
kubectl create -f nginx.yaml
# kubectl apply -f nginx.yaml will not work
kubectl get pods

# Port forwarding from 3000 local to 80 internal port
kubectl port-forward --address 0.0.0.0 nginx 3000:80