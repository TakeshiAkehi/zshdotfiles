PWD=$(shell pwd)
.SILENT: build

image:
	docker build -t dotfiles --force-rm -f docker/Dockerfile docker/

zsh:
	docker run --rm --name dotfiles -v ${PWD}:/root/dotfiles -it dotfiles /bin/zsh

bash:
	docker run --rm --name dotfiles -v ${PWD}:/root/dotfiles -it dotfiles /bin/bash
