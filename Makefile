APP=${shell basename $(shell git remote get-url origin) .git}
REGISTRY=andriiyer
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=amd64

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

clean:
	rm -rf kbot

build: clean format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/a-yerzhyk/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}
