VERSION=0.9.1
TARGETS_NOVENDOR=$(shell glide novendor)

nginx-build: *.go
	GO15VENDOREXPERIMENT=1 go build -o nginx-build

build-cross:
	GO15VENDOREXPERIMENT=1 GOOS=linux GOARCH=amd64 go build -ldflags '-s -w' -o bin/linux/amd64/nginx-build
	GO15VENDOREXPERIMENT=1 GOOS=darwin GOARCH=amd64 go build -ldflags '-s -w' -o bin/darwin/amd64/nginx-build

dist: build-cross
	cd bin/linux/amd64/ && tar zcvf nginx-build-linux-amd64-${VERSION}.tar.gz nginx-build
	cd bin/darwin/amd64/ && tar zcvf nginx-build-darwin-amd64-${VERSION}.tar.gz nginx-build

# ImageMagick and GD are required for ngx_small_light
build-example: nginx-build
	./nginx-build -c config/configure.example -m config/modules.cfg.example -d work -clear

bundle:
	glide install

check:
	GO15VENDOREXPERIMENT=1 go test $(TARGETS_NOVENDOR)

fmt:
	@echo $(TARGETS_NOVENDOR) | xargs go fmt

install:
	install nginx-build /usr/local/bin/nginx-build
	install doc/_build/man/nginx-build.7 /usr/local/share/man/man7/nginx-build.7

.PHONY: doc
doc:
	cd doc; make man

clean:
	rm -rf nginx-build
	rm -rf bin/linux/amd64/nginx-build*
	rm -rf bin/darwin/amd64/nginx-build*
