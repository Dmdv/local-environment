# Questions

1. How to bind PV to a specific location on the host? - `In minukube its PVC and PV are standard and not deleted.`
2. How to change default namespace of helm chart? - `helm install redis-local bitnami/redis --create-namespace --namespace redis-local`
3. How to specify the number of replicas? - `Create yaml property files`
4. How to change the default password using value file - `Create yaml property files`
5. How to connect to Redis from the cluster? DNS name? - Check logs after deployment. It will display names.
6. Do we need sentinel in redis and redis cluster?