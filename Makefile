APP=${shell basename $(shell git remote get-url origin) .git}
REGISTRY=ghcr.io/a-yerzhyk
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS?=linux
TARGETARCH?=amd64

.PHONY: format lint test get clean pre-build build image push linux windows macos

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

clean:
	@echo Removing kbot binary
	rm -rf kbot
	@echo Removing docker image
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH} || true

pre-build: format get

build: pre-build
	@echo Building for ${TARGETOS}/${TARGETARCH}
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/a-yerzhyk/kbot/cmd.appVersion=${VERSION}

# Detect current architecture
CURRENT_ARCH=$(shell uname -m)
ifeq ($(CURRENT_ARCH),x86_64)
    DETECTED_ARCH=amd64
else ifeq ($(CURRENT_ARCH),aarch64)
    DETECTED_ARCH=arm64
else ifeq ($(CURRENT_ARCH),armv7l)
    DETECTED_ARCH=arm
else
    DETECTED_ARCH=
endif

ifeq ($(DETECTED_ARCH),)
	$(error No supported architecture detected)
endif

linux: pre-build
	@echo Building for linux/${DETECTED_ARCH}
	CGO_ENABLED=0 GOOS=linux GOARCH=${DETECTED_ARCH} go build -v -o kbot -ldflags "-X=github.com/a-yerzhyk/kbot/cmd.appVersion=${VERSION}"

windows: pre-build
	@echo Building for windows/${DETECTED_ARCH}
	CGO_ENABLED=0 GOOS=windows GOARCH=${DETECTED_ARCH} go build -v -o kbot -ldflags "-X=github.com/a-yerzhyk/kbot/cmd.appVersion=${VERSION}"

macos: pre-build
	@echo Building for darwin/${DETECTED_ARCH}
	CGO_ENABLED=0 GOOS=darwin GOARCH=${DETECTED_ARCH} go build -v -o kbot -ldflags "-X=github.com/a-yerzhyk/kbot/cmd.appVersion=${VERSION}"

# Detect current OS
CURRENT_OS=$(shell uname -s)
ifeq ($(CURRENT_OS),Linux)
    DETECTED_OS=linux
else ifeq ($(CURRENT_OS),Darwin)
    DETECTED_OS=darwin
else ifeq ($(CURRENT_OS),MINGW*)
    DETECTED_OS=windows
else ifeq ($(CURRENT_OS),MSYS*)
    DETECTED_OS=windows
else ifeq ($(CURRENT_OS),CYGWIN*)
    DETECTED_OS=windows
else
    DETECTED_OS=
endif

ifeq ($(DETECTED_OS),)
	$(error No supported OS detected)
endif

image: clean
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${DETECTED_ARCH} \
		--build-arg TARGETOS=${DETECTED_OS} \
		--build-arg TARGETARCH=${DETECTED_ARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${DETECTED_ARCH}
