# Getting access to Redis cluster

## Prerequisites

- Namespace: redis
- Helm: redis
- Name: redis

Under such configuration we will find redis inside the cluster under following FQDNS:

```
redis-master.redis.svc.cluster.local for read/write operations (port 6379)
redis-replicas.redis.svc.cluster.local for read-only operations (port 6379)
```

## Password
```shell
export REDIS_PASSWORD=$(kubectl get secret --namespace redis redis -o jsonpath="{.data.redis-password}" | base64 -d)
```

## Run Redis client
```shell
kubectl run -n redis redis-client --restart='Never' --env REDIS_PASSWORD=$REDIS_PASSWORD --image docker.io/bitnami/redis:7.2.3-debian-11-r1 --command -- sleep infinity
```

or if you want to delete the pod after exiting:
```shell
kubectl run -n redis redis-client --restart='Never' --rm --tty -i --env REDIS_PASSWORD=$REDIS_PASSWORD --image docker.io/bitnami/redis:7.2.3-debian-11-r1 -- bash
```

## Connect

You can connect to Redis using:

1. Redis-client pod (should be installed first)
2. Port-forward and addressing to localhost using redis-cli
3. Pod shell and addressing to localhost using redis-cli

### Attach to the pod

To connect to the client
```shell
kubectl -n redis exec --tty -i redis-client -- bash
```

or to connect to the master:
```shell
kubectl -n redis exec -it redis-master-0 -- sh
```

or to connect to replica:
```shell
kubectl -n redis exec -it redis-replicas-0 -- sh
```

### Connect with port-forward

With it, you can connect to the Redis server from outside the cluster.

```shell
kubectl port-forward --namespace redis svc/redis-master 6379:6379
// or
kubectl port-forward --namespace redis svc/redis-headless 6379:6379
```

and then connect to the Redis server using redis-cli:
```shell
REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h 127.0.0.1 -p 6379
```

### Connect using pod shell

Using this command is possible only after attaching to the pod:
```shell
kubectl -n redis exec --tty -i redis-client -- sh
```

or to the master, or replica:
```shell
kubectl -n redis exec --tty -i redis-master-0 -- sh
```

#### Attached to the redis-client pod

When you connected through the redis client, you can use this command to connect to the master.
```shell
REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h redis-master
```

#### Attached to the master/replica pod

But if you connected directly to the master/replica, then you can use this command:
```shell
REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli
```
