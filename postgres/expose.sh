# Expose service as a nodeport
kubectl expose deployment postgres --type=NodePort
# Expose service as a loadbalancer
kubectl expose deployment postgres --type=LoadBalancer --name=postgres-exp
