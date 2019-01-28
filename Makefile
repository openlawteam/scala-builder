ORG = openlaw
TAG = $(ORG)/scala-sbt

.PHONY: image
image:
	docker build -t $(TAG) .
