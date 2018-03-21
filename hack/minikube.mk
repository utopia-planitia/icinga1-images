 
.PHONY: start
start: ##@setup Starts minikube.
	$(MAKE) init
	$(MAKE) await

.PHONY: init
init:
	./hack/start-minikube.sh
	minikube update-context

.PHONY: await
await:
	./hack/await-minikube.sh

.PHONY: stop
stop: ##@setup Stops minikube.
	sudo -E systemctl stop localkube
	docker ps -aq --filter name=k8s | xargs -r docker rm -f

.PHONY: logs
logs: ##@setup Shows logs.
	ktail -n container-image-builder
