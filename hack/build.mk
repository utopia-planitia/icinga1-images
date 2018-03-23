
.server-deploy: .server kubernetes/server.yaml
	kubectl apply -f kubernetes/server.yaml
	kubectl -n alerting delete po -l app=server
	touch .server-deploy

.client-deploy: .client kubernetes/client.yaml
	kubectl apply -f kubernetes/client.yaml
	kubectl -n alerting delete po -l app=client
	touch .client-deploy

.devtools: $(shell find hack/devtools -type f)
	docker build -t utopiaplanitia/alerting-devtools:latest hack/devtools
	touch .devtools

.server: .secrets $(shell find server -type f)
	docker build -t utopiaplanitia/alerting-server:latest server
	touch .server

.client: .secrets $(shell find client -type f)
	docker build -t utopiaplanitia/alerting-client:latest client
	touch .client

.secrets: secrets/create.sh
	docker build -t utopiaplanitia/alerting-devtools:latest hack/devtools
	docker run -ti --rm \
		--dns 10.96.0.10 --dns-search container-image-builder.svc.cluster.local \
		-e DOCKER_HOST=tcp://docker:2375 \
		-v $(PWD):/project -w /project/secrets \
		utopiaplanitia/alerting-devtools:latest sh create.sh
	touch .secrets
