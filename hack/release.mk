
.PHONY: build-push
build-push: ##@release Build and push the images.
	docker build -f server/Dockerfile        -t utopiaplanitia/alerting-server:latest .
	docker build -f hack/devtools/Dockerfile -t utopiaplanitia/alerting-devtools:latest .
	docker build -f client/Dockerfile        -t utopiaplanitia/alerting-client:latest .
	docker push utopiaplanitia/alerting-client:latest
	docker push utopiaplanitia/alerting-devtools:latest
	docker push utopiaplanitia/alerting-server:latest