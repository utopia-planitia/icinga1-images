
.PHONY: cli
cli: .devtools ##@development Opens a command line interface with development tools.
	docker run -ti --rm \
		--dns 10.96.0.10 --dns-search container-image-builder.svc.cluster.local \
		-e DOCKER_HOST=tcp://docker:2375 \
		-v $(PWD):/project -w /project \
		utopiaplanitia/alerting-devtools:latest bash

.PHONY: cli-server
cli-server: ##@development Opens a command line interface to the server.
	kubectl -n alerting exec -ti $(shell kubectl -n alerting get po -o=jsonpath='{.items[0].metadata.name}' -l app=server) bash

.PHONY: cli-client
cli-client: ##@development Opens a command line interface to the client.
	kubectl -n alerting exec -ti $(shell kubectl -n alerting get po -o=jsonpath='{.items[0].metadata.name}' -l app=client) bash

.PHONY: deploy
deploy: .server .client .devtools ##@development Deploys the current code.
	kubectl apply -f kubernetes/namespace.yaml -f kubernetes
	./hack/restart-pods.sh
	docker run -ti --rm \
		--dns 10.96.0.10 --dns-search alerting.svc.cluster.local \
		-e DOCKER_HOST=tcp://docker:2375 \
		-v $(PWD):/project -w /project \
		utopiaplanitia/alerting-devtools:latest ./hack/await-open-ports.sh

.PHONY: open
open: ##@development Open icinga dashboard in browser.
	minikube service -n alerting server

.PHONY: redeploy
redeploy: .server-deploy .client-deploy ##@development Redeploys changed code.
	./hack/await-pods.sh
	docker run -ti --rm \
		--dns 10.96.0.10 --dns-search alerting.svc.cluster.local \
		-e DOCKER_HOST=tcp://docker:2375 \
		-v $(PWD):/project -w /project \
		utopiaplanitia/alerting-devtools:latest ./hack/await-open-ports.sh
