# NATS installation

## nats-box

Nats-box is a lightweight container with NATS utilities.

- nats - NATS management utility (README)
- nsc - create NATS accounts and users
- nats-top - top-like tool for monitoring NATS servers

https://github.com/nats-io/nats-box

## Repo init
```shell
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
```
Values:
- https://artifacthub.io/packages/helm/nats/nats

## Install
```shell
helm install nats nats/nats --create-namespace --namespace nats -f values.yaml
```

## CRD: JetStream controllers
Controllers:
- https://github.com/nats-io/nack

Install:
- https://github.com/nats-io/nack#getting-started

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