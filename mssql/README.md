# Local MSSQL instance

## Setup

Make sure following is installed:

```shell
/Users/$USER/sql/data/
```

## Install

There 2 ways to install MSSQL locally in docker with the same results:

- sqlcmd
- docker

### sqlcmd

Install sqlcmd 
```shell
brew install sqlcmd
```
```shell
sqlcmd create mssql --accept-eula --using https://aka.ms/AdventureWorksLT.bak
```

### docker

```shell
docker run --name=mssql --mount type=bind,source=/Users/$USER/sql/data/,target=/var/opt/mssql/data/ \ 
 --user=mssql --env=ACCEPT_EULA=Y --env=MSSQL_SA_PASSWORD='*p#iJ$E1ixXC%88vxZ4YH6SV4@H$Q@!M@d@p7O#0o0*5YMI4Ts' \
 --env=MSSQL_COLLATION=SQL_Latin1_General_CP1_CI_AS --env=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
 --env=MSSQL_RPC_PORT=135 --env=CONFIG_EDGE_BUILD= --env=MSSQL_PID=developer -p 1433:1433 \
 --label='com.microsoft.product=Microsoft SQL Server' \
 --label='com.microsoft.version=16.0.4105.2' \
 --label='org.opencontainers.image.ref.name=ubuntu' \
 --label='org.opencontainers.image.version=22.04' \
 --label='vendor=Microsoft' \
 --runtime=runc -t -d mcr.microsoft.com/mssql/server:latest
```

Credentials:

```
sa
*p#iJ$E1ixXC%88vxZ4YH6SV4@H$Q@!M@d@p7O#0o0*5YMI4Ts
```

Instead of used `mount`, you can use volume:

```shell
-v sqlvolume:/var/opt/mssql
```