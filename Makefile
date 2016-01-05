IMAGE=speeddigital/jenkins-swarm:latest

.PHONY: build push

build:
	docker build -t $(IMAGE) .

push:
	docker push $(IMAGE)

