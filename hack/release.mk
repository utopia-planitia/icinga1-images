
export TAG=$(shell date +%s)
export CLIENT_IMAGE="registry/alerting/client:${TAG}"
export SERVER_IMAGE="registry/alerting/server:${TAG}"
KUBECTL ?= kubectl

.PHONY: release
release: .client-pushed .server-pushed ##@release Build and push the images.
	$(MAKE) apply TAG=${TAG}

.PHONY: apply
apply: ##@release Apply monitoring to the cluster.
	cat kubernetes/release/namespace.yaml | envsubst | $(KUBECTL) --context=matrix apply -f -
	cat kubernetes/release/client.yaml | envsubst | $(KUBECTL) --context=matrix apply -f -
	cat kubernetes/release/server.yaml | envsubst | $(KUBECTL) --context=matrix apply -f -
	$(KUBECTL) --context=matrix -n alerting delete po --all

.PHONY: .client-pushed
.client-pushed: .client
	docker tag utopiaplanitia/alerting-client:latest ${CLIENT_IMAGE}
	docker push ${CLIENT_IMAGE}
	touch .client-pushed

.PHONY: .server-pushed
.server-pushed: .server
	docker tag utopiaplanitia/alerting-server:latest ${SERVER_IMAGE}
	docker push ${SERVER_IMAGE}
	touch .server-pushed
