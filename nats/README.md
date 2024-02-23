# NATS installation

## Environment

- Minikube
- Docker-desktop

If you use minikube, you should enable `registry-creds` addon.\
If you fail to install minukube, you can use docker-desktop.\
If you use docker-desktop, you should enable Kubernetes and never enable `containerd` daemon for pulling images.

## Installation

NATS installation comes in 3 stages:
1. Helm installation
2. Client installation
3. CRD installation

## Helm repo init

```shell
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
```
Values description:
- https://artifacthub.io/packages/helm/nats/nats

### Install
```shell
helm install nats nats/nats --create-namespace --namespace nats -f values.yaml
```

## NATS-BOX client installation

```shell
kubectl run -i --rm --tty nats-box --image=natsio/nats-box --restart=Never
```

NATS-BOX is a lightweight container with NATS utilities.

- nats - NATS management utility (README)
- nsc - create NATS accounts and users
- nats-top - top-like tool for monitoring NATS servers

https://github.com/nats-io/nats-box

## CRD: JetStream controllers

It will enable stream, consumer and account CRDs.

Controllers:
- https://github.com/nats-io/nack

Installation:
- https://github.com/nats-io/nack#getting-started

Using shell:
```shell
kubectl apply -f crd.conf
```

Install stream and consumers using operators:

```
# Create a stream.
$ kubectl apply -f https://raw.githubusercontent.com/nats-io/nack/main/deploy/examples/stream.yml

# Check if it was successfully created.
$ kubectl get streams
NAME       STATE     STREAM NAME   SUBJECTS
mystream   Created   mystream      [orders.*]

# Create a push-based consumer
$ kubectl apply -f https://raw.githubusercontent.com/nats-io/nack/main/deploy/examples/consumer_push.yml

# Create a pull based consumer
$ kubectl apply -f https://raw.githubusercontent.com/nats-io/nack/main/deploy/examples/consumer_pull.yml

# Check if they were successfully created.
$ kubectl get consumers
NAME               STATE     STREAM     CONSUMER           ACK POLICY
my-pull-consumer   Created   mystream   my-pull-consumer   explicit
my-push-consumer   Created   mystream   my-push-consumer   none

# If you end up in an Errored state, run kubectl describe for more info.
#     kubectl describe streams mystream
#     kubectl describe consumers my-pull-consumer
```

## Troubleshooting using NATS BOX

Repo: https://github.com/nats-io/nats-box

Use tools to interact with NATS.

Running in Docker:

```
$ docker run --rm -it natsio/nats-box:latest
~ # nats pub -s demo.nats.io test 'Hello World'
16:33:27 Published 11 bytes to "test"
```

Running in Kubernetes:

```
kubectl run -it --rm nats-box --image=natsio/nats-box --restart=Never -- nats sub -s demo.nats.io test
```

or 

```
# Interactive mode
kubectl run -i --rm --tty nats-box --image=natsio/nats-box --restart=Never
nats-box:~# nats sub -s nats hello &
nats-box:~# nats pub -s nats hello world

# Non-interactive mode
kubectl apply -f https://nats-io.github.io/k8s/tools/nats-box.yml
kubectl exec -it nats-box -- /bin/sh
```
