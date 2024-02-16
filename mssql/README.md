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

Check docker-compose.yml for the latest version of MSSQL. \
And if you see any issues with the current image, you can change it to \
https://github.com/cagrin/azure-sql-edge-arm64

```shell
docker-compose up -d
```
