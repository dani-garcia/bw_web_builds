#!/usr/bin/env bash

set -e

if [[ -z "$VAULT_VERSION" ]] ; then
	echo "Missing VAULT_VERSION cannot build"
	exit 1
fi

mkdir vault;
cd vault;
git -c init.defaultBranch=main init
git remote add origin https://github.com/bitwarden/clients.git
git fetch --depth 1 origin "${VAULT_VERSION}"
git -c advice.detachedHead=false checkout FETCH_HEAD

../scripts/apply_patches.sh
npm ci
cd -

cd vault/apps/web
npm run dist:oss:selfhost
find build -name "*.map" -delete
cd -

mv vault/apps/web/build web-vault
