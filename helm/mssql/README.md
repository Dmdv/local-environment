# MSSQL

## Overview
This chart is created not for production but for local env to start development environment locally.

## Prepare migration

1. Open `values.xml` and replace `hostPath` with the current manifest folder location.
2. Create namespace mssql
3. Use namespace mssql
4. Install helm chart with dev name

Name `dev-mssql.mssql.svc.cluster.local` is hardcoded in scripts

## Migrations scripts

`hostPath` should contain absolute path to the migration scripts.
'run.sh' should have reference to the server in FQND format: \
<service>.<namespace>.svc.cluster.local
```
dev-mssql.mssql.svc.cluster.local
```

```bash

```yaml
sqlcmd:
  image: mcr.microsoft.com/mssql-tools:latest
  mountPath: /opt/migration
  hostPath: <absolute path>/migration
  scriptName: run.sh
```

## Install

```shell
helm install dev ./mssql --create-namespace --namespace mssql
```