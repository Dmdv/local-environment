# Mongo

Mongo can be installed with bitnami helm. \
But on ARM64 platform, it is not available.

To solve this issue, we can use the following steps from \
https://copyprogramming.com/howto/launch-mongodb-built-from-source-on-arm:

```shell
helm install mongodb bitnami/mongodb
  --set image.repository=arm64v8/mongo
  --set image.tag=latest
  --set persistence.mountPath=/data/db
```

## More

https://github.com/bitnami/charts/issues/16247 \
https://github.com/bitnami/charts/issues/3635 \
https://github.com/bitnami/charts/issues/10255 \
https://www.mongodb.com/docs/manual/administration/production-notes/#platform-support 
