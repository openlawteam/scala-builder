ORG = openlaw
NAME = $(ORG)/scala-builder

.PHONY: slim node
default: slim node
slim:
	docker build -t $(NAME):latest -t $(NAME):slim .

node: slim
	docker build -f Dockerfile.node -t $(NAME):node .
