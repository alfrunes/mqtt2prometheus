GOBINARY := go
DOCKERBINARY := docker

VERSION := $(shell git describe --tag --dirty)
LDFLAGS := -s -w
BUILDFLAGS := -trimpath
GOARCH := $(shell $(GOBINARY) env GOARCH)
GOOS := $(shell $(GOBINARY) env GOOS)
GOARM := $(shell $(GOBINARY) env GOARM)

TARGET_FILE := bin/mqtt2prometheus_$(GOOS)_$(GOARCH)$(GOARM)
SRC := $(shell go list -f '{{$$dir := .Dir}}{{range .GoFiles}}{{printf "%s/%s\n" $$dir .}}{{end}}' ./...)

# Container
REGISTRY := docker.io
REPOSITORY := alfrunes/mqtt2prometheus
TAG := latest

.PHONY: all lint test build container
all: build

lint:
	golangci-lint run

test:
	$(GOBINARY) test ./...
	$(GOBINARY) vet ./...

$(TARGET_FILE): $(SRC)
	/usr/bin/env \
		CGO_ENABLED=0 \
		GOOS=$(GOOS) \
		GOARCH=$(GOARCH) \
		$(GOBINARY) build \
		-ldflags '$(LDFLAGS)' \
		-ldflags '-X main.version=$(VERSION)' \
		$(BUILDFLAGS) \
		-o $(TARGET_FILE) ./cmd

build: $(TARGET_FILE)

container:
	$(DOCKERBINARY) build -t $(REGISTRY)$(REPOSITORY):$(TAG) .
