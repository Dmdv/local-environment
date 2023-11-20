# Helper rules

.PHONY: init install uninstall

init: ## Initializes helm chart
	@cd ./redis && make init && cd ..
	@cd ./nats && make init

install: ## Installs helm chart
	@cd ./redis && make install && cd ..
	@cd ./nats && make install

uninstall: ## Installs helm chart
	@cd ./redis && make uninstall && cd ..
	@cd ./nats && make uninstall

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