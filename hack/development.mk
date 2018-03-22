
.PHONY: cli
cli: .devtools ##@development Opens a command line interface with development tools.
	docker run -ti --rm \
		--dns 10.96.0.10 --dns-search container-image-builder.svc.cluster.local \
		-e DOCKER_HOST=tcp://docker:2375 \
		-v $(PWD):/project -w /project \
		utopiaplanitia/alerting-devtools:latest bash

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

.PHONY: logs
logs: ##@development Show logs.
	ktail -n alerting

.PHONY: redeploy
redeploy: .dispatcher-deploy .worker-deploy ##@development Redeploys changed code.
	kubectl apply -f kubernetes/mirror.yaml -f kubernetes/cache.yaml
	./hack/await-pods.sh
	docker run -ti --rm \
		--dns 10.96.0.10 --dns-search alerting.svc.cluster.local \
		-e DOCKER_HOST=tcp://docker:2375 \
		-v $(PWD):/project -w /project \
		utopiaplanitia/alerting-devtools:latest ./hack/await-open-ports.sh

.server-deploy: .server kubernetes/server.yaml
	kubectl apply -f kubernetes/server.yaml
	kubectl -n alerting delete po -l app=server
	touch .dispatcher-deploy

.client-deploy: .client kubernetes/client.yaml
	kubectl apply -f kubernetes/client.yaml
	kubectl -n alerting delete po -l app=client
	touch .worker-deploy

.devtools: $(shell find hack/devtools -type f)
	docker build -t utopiaplanitia/alerting-devtools:latest hack/devtools
	touch .devtools

.server: $(shell find server -type f)
	docker build -t utopiaplanitia/alerting-server:latest server
	touch .server

.client: $(shell find client -type f)
	docker build -t utopiaplanitia/alerting-client:latest client
	touch .client
