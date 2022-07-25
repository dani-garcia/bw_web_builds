SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:

help:
	@echo "Use either: clean, checkout, patch-web-vault, generate-patch, build, tar, or full"
	@echo "Or for docker builds use: docker or docker-extract"
.PHONY: help

clean:
	rm -rvf "./web-vault"
	rm -rvf "./builds"
	rm -rvf "./docker_builds"
.PHONY: clean

checkout:
	./scripts/checkout_web_vault.sh
.PHONY: checkout

patch-web-vault:
	./scripts/patch_web_vault.sh
.PHONY: patch-web-vault

generate-patch:
	./scripts/generate_patch_file.sh
.PHONY: generate-patch

build:
	./scripts/build_web_vault.sh
.PHONY: checkout

tar:
	./scripts/tar_web_vault.sh
.PHONY: tar

full: checkout patch-web-vault build tar
.PHONY: full

docker:
	docker build -t bw_web_vault .
.PHONY: docker

docker-extract: docker
	@docker rm bw_web_vault_extract || true
	@docker create --name bw_web_vault_extract bw_web_vault
	@mkdir -vp docker_builds
	@rm -rf ./docker_builds/bw_web_vault.tar.gz ./docker_builds/web-vault
	@docker cp bw_web_vault_extract:/bw_web_vault.tar.gz ./docker_builds/bw_web_vault.tar.gz
	@docker cp bw_web_vault_extract:/web-vault ./docker_builds/web-vault
	@docker rm bw_web_vault_extract || true
.PHONY: docker-extract

native-build:
	git clone https://github.com/bitwarden/clients.git vault
	cd vault
	git -c advice.detachedHead=false checkout $(HASH)
	cd vault
	cp ../scripts/apply_patches.sh apply_patches.sh
	bash apply_patches.sh
	npm ci
	npm audit fix || true
	cd apps/web
	npm run dist:oss:selfhost
