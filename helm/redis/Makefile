.PHONY: init install uninstall password tunnel shell install-client

init: ## Initializes helm chart
	@helm repo add bitnami https://charts.bitnami.com/bitnami

install: ## Installs helm chart
	@helm install redis bitnami/redis --create-namespace --namespace redis -f values.yaml

install-client: ## Installs redis client
	@kubectl run -n redis redis-client --restart='Never' --env REDIS_PASSWORD=$REDIS_PASSWORD --image docker.io/bitnami/redis:7.2.3-debian-11-r1 --command -- sleep infinity

uninstall: ## Uninstalls helm chart
	@helm uninstall redis -n redis

set-password: ## Set password
	@export REDIS_PASSWORD=$(kubectl get secret -n redis redis -o jsonpath="{.data.redis-password}" | base64 -d)

password: ## Prints password
	@kubectl get secret -n redis redis -o jsonpath="{.data.redis-password}" | base64 --decode ; echo

tunnel: ## Opens tunnel
	@kubectl port-forward --namespace redis svc/redis-headless 6379:6379

shell: ## Opens shell
	@kubectl -n redis exec --tty -i redis-client -- bash

# Helper rules

.PHONY: list
list: ## List all make targets
	@${MAKE} -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort

.PHONY: help
.DEFAULT_GOAL := help
help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Variable outputting/exporting rules
var-%: ; @echo $($*)
varexport-%: ; @echo $*=$($*)