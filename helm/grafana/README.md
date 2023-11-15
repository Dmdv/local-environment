# Grafana setup

https://github.com/grafana/helm-charts/blob/main/charts/grafana/README.md

- Name: grafana
- Namespace: default
- Repo: grafana/grafana

## Install

```shell
helm install grafana grafana/grafana
```

## Admin password

```bash
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

## Access

The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:

```
grafana.default.svc.cluster.local
```

## Get pod name

```shell
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
```

## Port forward

```shell
kubectl --namespace default port-forward $POD_NAME 3000
```