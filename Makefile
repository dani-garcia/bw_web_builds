SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:

help:
	@echo "Use either: clean, checkout, build, tar, or full"
	@echo "Or for container builds use: container or container-extract"
	@echo
	@echo "By default docker is used, you can force podman by using podman or podman-extract"
	@echo "You can also define the default via a '.env' file, see the '.env.template' for details"
	@echo
	@echo "For releasing a new version you can use gh-prepare and gh-release"
	@echo
.PHONY: help

# Load .env variables if the file exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Force docker to output the progress in plain
BUILDKIT_PROGRESS=plain

ifndef CONTAINER_CMD
  CONTAINER_CMD = docker
endif

clean:
	rm -rvf ./web-vault
	rm -rvf ./builds
	rm -rvf ./docker_builds
	rm -rvf ./container_builds
	rm -vf ./bw_web_v*.tar.gz*
	rm -vf sha256sums.txt
.PHONY: clean

checkout:
	./scripts/checkout_web_vault.sh
.PHONY: checkout

build:
	./scripts/build_web_vault.sh
.PHONY: build

tar:
	./scripts/tar_web_vault.sh
.PHONY: tar

full: checkout build tar
.PHONY: full

container:
	${CONTAINER_CMD} build -t bw_web_vault .
.PHONY: container

container-extract: container
	@${CONTAINER_CMD} rm bw_web_vault_extract 2>/dev/null || true
	@${CONTAINER_CMD} create --name bw_web_vault_extract bw_web_vault
	@mkdir -vp container_builds
	@rm -rf ./container_builds/bw_web_vault.tar.gz ./container_builds/web-vault
	@${CONTAINER_CMD} cp bw_web_vault_extract:/bw_web_vault.tar.gz ./container_builds/bw_web_vault.tar.gz
	@${CONTAINER_CMD} cp bw_web_vault_extract:/web-vault ./container_builds/web-vault
	@${CONTAINER_CMD} rm bw_web_vault_extract || true
.PHONY: container-extract

# Alias for container forcing docker
docker: CONTAINER_CMD := docker
docker: container
.PHONY: docker

# Alias for container forcing docker
docker-extract: CONTAINER_CMD := docker
docker-extract: container-extract
.PHONY: docker-extract

# Alias for container forcing podman
podman: CONTAINER_CMD := podman
podman: container
.PHONY: podman

# Alias for container forcing podman
podman-extract: CONTAINER_CMD := podman
podman-extract: container-extract
.PHONY: podman-extract

# This part is used for extracing and release a new version on Github
gh-prepare:
	./scripts/gh_prepare.sh
.PHONY: gh-prepare

gh-release:
	./scripts/gh_release.sh
.PHONY: gh-release
