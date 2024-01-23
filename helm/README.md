# Helm collection for local environment

## Usage
In this folder you can find helm charts for local development.
To install the specific service, use Makefile, and read README.md for next steps.

It will install following services:
- Redis
- NATS JetStream

```shell
make install
```

```shell
make uninstall
```

## Pre-requisites
- Minikube
- Skaffold (optional)