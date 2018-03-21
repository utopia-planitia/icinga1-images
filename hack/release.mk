
.PHONY: build-push
build-push: ##@release Build and push the images.
	docker build -f docker/dispatcher/Dockerfile -t utopiaplanitia/alerting-server:latest .
	docker build -f docker/devtools/Dockerfile   -t utopiaplanitia/alerting-devtools:latest .
	docker build -f docker/builder/Dockerfile    -t utopiaplanitia/alerting-client:latest .
	docker push utopiaplanitia/alerting-client:latest
	docker push utopiaplanitia/alerting-devtools:latest
	docker push utopiaplanitia/alerting-server:latest
