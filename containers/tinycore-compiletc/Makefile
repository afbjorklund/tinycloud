DOCKER = docker

IMAGE_NAME := tinycore-compiletc
IMAGE_TAG := 15.0-x86_64

.PHONY: all clean build

all: build

build:
	$(DOCKER) build -t $(IMAGE_NAME):$(IMAGE_TAG) .

clean:
	$(DOCKER) images $(IMAGE_NAME):$(IMAGE_TAG) && $(DOCKER) rmi $(IMAGE_NAME):$(IMAGE_TAG) || true
