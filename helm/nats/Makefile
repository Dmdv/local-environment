# Helper rules

.PHONY: install uninstall password init shell

init: ## Initializes helm chart
	@helm repo add nats https://nats-io.github.io/k8s/helm/charts

install: ## Installs helm chart
	@helm install nats nats/nats --create-namespace --namespace nats -f values.yaml

uninstall: ## Uninstalls helm chart
	@helm uninstall nats -n nats

password: ## Prints password
	@kubectl get secret --namespace nats nats -o jsonpath="{.data.NATS_PASSWORD}" | base64 --decode ; echo

shell: ## Opens shell
	@kubectl exec -n nats -it deployment/nats-box -n nats -- /bin/sh -l

tunnel: ## Opens tunnel
	@kubectl port-forward --namespace nats svc/nats 4222:4222

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