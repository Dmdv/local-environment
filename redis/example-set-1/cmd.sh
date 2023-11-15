#!/usr/bin/env bash

# NOTE: This script is for reference only.

# Run redis-cli
kubectl exec -it redis -- redis-cli

# Get configmap
kubectl describe configmap/redis-config