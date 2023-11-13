#!/usr/bin/env bash

# Bitnami Redis
helm install redis-test bitnami/redis

# DO NOT USER this - example using values
helm install --name redis-cluster -f redis-value.yaml stable/redis

# Checking all pods
kubectl get pods -o wide

# Check service
kubectl get svc -n redis-cluster

# Port forward
kubectl port-forward -n redis-cluster service/redis-server-redis-cluster --address 0.0.0.0 8080:6379

# Using redis-cli
redis-cli -c -h 127.0.0.1 -p 8080 -a 'xxxx'
kubectl -n redis exec -it redis-0 -- sh