# Using Helm

## Redis

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install redis-test bitnami/redis
```

## Redis Cluster

```shell
helm search repo bitnami/redis-cluster --versions
```

### Storage class

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Delete
```

### The flow that just works

- https://www.airplane.dev/blog/deploy-redis-cluster-on-kubernetes
- https://bitnami.com/stack/redis/helm

### PersistentVolume

- redis-pv.yaml

### Config map

- redis-config.yaml

### StatefulSet

- redis-statefulset.yaml

### Shell

```shell
kubectl -n redis exec -it redis-0 -- sh
```
