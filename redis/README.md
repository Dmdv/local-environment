# Redis

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

https://www.dragonflydb.io/guides/redis-kubernetes