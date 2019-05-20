.SILENT: help
SHELL = /bin/bash
.DEFAULT_GOAL := help

PROJECT := dockerfile-gen

HOME = $(shell pwd)

submodules-update:
	git submodule update --recursive --remote

packr:
	@packr clean && packr

## Setup of the project
setup:
	@go get -u github.com/golangci/golangci-lint/cmd/golangci-lint
	@go get -u github.com/golang/dep/...
	@go get -u github.com/gobuffalo/packr/packr
	@make vendor-install

## Install dependencies of the project
vendor-install:
	@dep ensure -v

## Update dependencies of the project
vendor-update:
	@dep ensure -update

## Visualizing dependencies status of the project
vendor-status:
	@dep status

## Visualizing dependencies
vendor-view:
	@brew install graphviz
	@dep status -dot | dot -T png | open -f -a /Applications/Preview.app

lint: ## Run all the linters
	golangci-lint run --skip-dirs official-images


COLOR_RESET = \033[0m
COLOR_COMMAND = \033[36m
COLOR_YELLOW = \033[33m
COLOR_GREEN = \033[32m
COLOR_RED = \033[31m

## Prints this help
help:
	printf "${COLOR_YELLOW}dockerfile-gen\n------\n${COLOR_RESET}"
	awk '/^[a-zA-Z\-\_0-9\.%]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "${COLOR_COMMAND}$$ make %s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST) | sort
	printf "\n"
