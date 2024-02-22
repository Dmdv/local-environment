# MSSQL

## Overview

This chart is created not for production but for local env to start development environment locally.

## Install

```shell
helm install dev ./mssql
```

## Migrations scripts

`hostPath` should contain absolute path to the migration scripts.
'run.sh' should have reference to the server in FQND format:
```
mssql.mssql.svc.cluster.local
```

Therefore, service name as `mssql` is hardcoded in chart because it would depend on the release name.


```bash

```yaml
sqlcmd:
  image: mcr.microsoft.com/mssql-tools:latest
  mountPath: /opt/migration
  hostPath: <absolute path>/migration
  scriptName: run.sh
```