PWD=$(shell pwd)
.SILENT: build

image:
	docker build -t dotfilesdev --force-rm -f docker/DockerfileDev docker/
	docker build -t dotfilesdemo --force-rm -f docker/DockerfileDemo docker/

bash:
	docker run --rm --name dotfilesdev -v ${PWD}:/root/zshdotfiles -it dotfilesdev /bin/bash

zsh:
	docker run --rm --name dotfilesdemo -it dotfilesdemo /bin/bash


