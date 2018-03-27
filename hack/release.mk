
export TAG=latest
export CLIENT_IMAGE_PUSH="registry/alerting/client:${TAG}"
export CLIENT_IMAGE_PULL="registry/alerting/client:${TAG}"
export SERVER_IMAGE_PUSH="registry/alerting/server:${TAG}"
export SERVER_IMAGE_PULL="registry/alerting/server:${TAG}"
KUBECTL ?= kubectl

.PHONY: release
release: .client-pushed .server-pushed ##@release Build and push the images.
	$(MAKE) apply TAG=${TAG}

.PHONY: apply
apply: ##@release Apply monitoring to the cluster.
	cat kubernetes/release/namespace.yaml | envsubst | $(KUBECTL) apply -f -
	cat kubernetes/release/client.yaml | envsubst | $(KUBECTL) apply -f -
	cat kubernetes/release/server.yaml | envsubst | $(KUBECTL) apply -f -
	$(KUBECTL) -n alerting delete po --all

.PHONY: .client-pushed
.client-pushed: .client
	docker tag utopiaplanitia/alerting-client:latest ${CLIENT_IMAGE_PUSH}
	docker push ${CLIENT_IMAGE_PUSH}
	touch .client-pushed

.PHONY: .server-pushed
.server-pushed: .server
	docker tag utopiaplanitia/alerting-server:latest ${SERVER_IMAGE_PUSH}
	docker push ${SERVER_IMAGE_PUSH}
	touch .server-pushed
