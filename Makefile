ORG = openlaw
TAG = $(ORG)/scala-builder

.PHONY: image
image:
	docker build -t $(TAG) .
