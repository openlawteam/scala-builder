ORG = openlaw
NAME = $(ORG)/scala-builder

# Release tags only match commits that exactly described by the ref of tag
# starting with "vX", example "v0.9" or "v1.2.3".
RELEASE_TAG := $(shell git describe --tag \
									--match "v[0-9]*" \
									--exact-match HEAD \
									2>/dev/null)

.PHONY: all alpine node tag-alpine tag-node publish lint

all: tag-alpine tag-node

alpine:
	docker build \
		--cache-from $(NAME):alpine \
		-t $(NAME):latest -t $(NAME):alpine .

node: alpine
	docker build -f Dockerfile.node \
		--cache-from $(NAME):node \
		-t $(NAME):node .

tag-alpine: alpine
	@ # if release version, add :X.Y.Z and :X.Y.Z-alpine to tags
	@ if [ ! -z ${RELEASE_TAG} ]; then \
		echo "Tagging alpine release images for $(RELEASE_TAG)" ;\
		docker tag $(NAME):alpine $(NAME):$(RELEASE_TAG:v%=%) ; \
		docker tag $(NAME):alpine $(NAME):$(RELEASE_TAG:v%=%)-alpine ; \
	fi

tag-node: node
	@ # if release version, add X.Y.Z-node to tags
	@ if [ ! -z ${RELEASE_TAG} ]; then \
		echo "Tagging node release images for $(RELEASE_TAG)" ;\
		docker tag $(NAME):node $(NAME):$(RELEASE_TAG:v%=%)-node ; \
	fi

publish:
	docker push $(NAME):alpine
	docker push $(NAME):node
	docker push $(NAME):latest
	docker push $(NAME):$(RELEASE_TAG:v%=%)
	docker push $(NAME):$(RELEASE_TAG:v%=%)-alpine
	docker push $(NAME):$(RELEASE_TAG:v%=%)-node

lint:
	docker run --rm -v $(PWD):/src replicated/dockerfilelint \
		/src/Dockerfile \
		/src/Dockerfile.node
