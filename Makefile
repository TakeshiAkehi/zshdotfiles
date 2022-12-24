PWD=$(shell pwd)
.SILENT: build

image:
	docker build -t dotfilesdev --force-rm -f docker/DockerfileDev docker/
	docker build -t dotfilesdev2 --force-rm -f docker/DockerfileDev2 docker/
	docker build -t dotfilesdemo --force-rm -f docker/DockerfileDemo docker/

bash:
	docker run --rm --name dotfilesdev -v ${PWD}:/root/zshdotfiles -it dotfilesdev /bin/bash

bash2:
	docker run --rm --name dotfilesdev2 -v ${PWD}:/root/zshdotfiles -it dotfilesdev2 /bin/bash

zsh:
	docker run --rm --name dotfilesdemo -it dotfilesdemo /bin/zsh


