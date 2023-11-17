# NATS installation

```shell
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
```

- https://artifacthub.io/packages/helm/nats/nats

## CRD

- https://github.com/nats-io/nack#getting-started

```shell
kubectl apply -f crd.conf
```