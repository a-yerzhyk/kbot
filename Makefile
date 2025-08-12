APP=${shell basename $(shell git remote get-url origin) .git}
REGISTRY=ghcr.io/a-yerzhyk
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS?=linux
TARGETARCH?=amd64

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

.PHONY: format lint test get clean pre-build build image push linux windows macos

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

pre-build: format get

build: pre-build
	@echo Building for ${TARGETOS}/${TARGETARCH}
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/a-yerzhyk/kbot/cmd.appVersion=${VERSION}

linux: pre-build
	@echo Building for linux/${DETECTED_ARCH}
	CGO_ENABLED=0 GOOS=linux GOARCH=${DETECTED_ARCH} go build -v -o kbot -ldflags "-X=github.com/a-yerzhyk/kbot/cmd.appVersion=${VERSION}"

# For use in WSL environment
windows: pre-build
	@echo Building for windows/${DETECTED_ARCH}
	CGO_ENABLED=0 GOOS=windows GOARCH=${DETECTED_ARCH} go build -v -o kbot -ldflags "-X=github.com/a-yerzhyk/kbot/cmd.appVersion=${VERSION}"

# For use on m1 mac and newer arm64 devices
macos: pre-build
	@echo Building for darwin/arm64
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -v -o kbot -ldflags "-X=github.com/a-yerzhyk/kbot/cmd.appVersion=${VERSION}"

clean:
	@echo Removing kbot binary
	rm -rf kbot
	@echo Removing docker image
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${DETECTED_ARCH} || true

image: clean
	@echo Building docker image for ${DETECTED_ARCH}
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${DETECTED_ARCH} \
		--build-arg TARGETARCH=${DETECTED_ARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${DETECTED_ARCH}
