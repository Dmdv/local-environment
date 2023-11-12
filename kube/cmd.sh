#!/usr/bin/env bash

# Create
kubectl apply -f nginx.yaml
kubectl get pods

# Port forwarding from 80 external to 3000 internal ports
kubectl port-forward --address 0.0.0.0 nginx 3000:80