ORG = openlaw
NAME = $(ORG)/scala-builder

# Release tags only match commits that exactly described by the ref of tag
# starting with "vX", example "v0.9" or "v1.2.3".
RELEASE_TAG := $(shell git describe --tag \
									--match "v[0-9]*" \
									--exact-match HEAD \
									2>/dev/null)

.PHONY: all slim node tag-slim tag-node

all: tag-slim tag-node

slim:
	docker build -t $(NAME):latest -t $(NAME):slim .

node: slim
	docker build -f Dockerfile.node -t $(NAME):node .

tag-slim: slim
	@ # if release version, add :X.Y.Z and :X.Y.Z-slim to tags
	@ if [ ! -z ${RELEASE_TAG} ]; then \
		echo "Tagging slim release images for $(RELEASE_TAG)" ;\
		docker tag $(NAME):slim $(NAME):$(RELEASE_TAG:v%=%) ; \
		docker tag $(NAME):slim $(NAME):$(RELEASE_TAG:v%=%)-slim ; \
	fi

tag-node: node
	@ # if release version, add X.Y.Z-node to tags
	@ if [ ! -z ${RELEASE_TAG} ]; then \
		echo "Tagging node release images for $(RELEASE_TAG)" ;\
		docker tag $(NAME):node $(NAME):$(RELEASE_TAG:v%=%)-node ; \
	fi

