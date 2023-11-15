#!/usr/bin/env bash

helm install redis bitnami/redis --create-namespace --namespace redis -f values.yaml