#!/usr/bin/env bash

# Run redis-cli
kubectl exec -it redis -- redis-cli

# Get configmap
kubectl describe configmap/redis-config