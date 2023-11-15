# Redis

This section contains examples of how redis can be started manually using custom manifests on the local cluster. \
This is not intended to be used in production.

## Files

- redis.k8s.simple.yaml - is deployment and service manifests combined.
- redis.k8s.yaml - is deployment and service manifests.
- redis-service.yaml - is service manifest.
- redis-deployment.yaml - is deployment manifest.
- redis-pod.yaml - is example pod manifest. It shows how to set up volume and env.
- redis-config.yaml - is example config map manifest. It shows how to set up config map.

## Some Redis-cli commands

```bash
127.0.0.1:6379> CONFIG GET maxmemory
```

## References

- https://www.dragonflydb.io/guides/redis-kubernetes
- https://www.airplane.dev/blog/deploy-redis-cluster-on-kubernetes
- https://phoenixnap.com/kb/kubernetes-redis

## Further development

Create persistent volume for backup data in your pod into local. \
If you delete pod, But your data still stored. Now create script file name redis-pv.yaml

### Step 1 — Prepare PV for Redis
Create persistent volume for backup data in your pod into local. \
If you delete pod, But your data still stored.

### Step 2
```shell
helm install --name redis-cluster -f redis-value.yaml stable/redis
```

### Step 3 - Step 3 — Connect using the Redis CLI
Now the service is ready to use, and you can connect to your redis server with Redis CLI command.\

```
redis-cluster-master for read/write operations
redis-cluster-slave for read-only operations
```

```shell
kubectl exec -it redis-cluster-master-0 bash
```

### Step 4
Execute into pod
```shell
kubectl exec -it redis -- redis-cli
```

```
redis-cli -h redis-cluster-master -a password
```
