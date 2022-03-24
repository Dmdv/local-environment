kubectl expose deployment postgres --type=NodePort
kubectl expose deployment postgres --type=LoadBalancer --name=postgres-exp
