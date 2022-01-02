#!/usr/bin/env bash
set -o pipefail -o errexit

# Error handling
handle_error() {
    read -n1 -r -p "FAILED: line $1, exit code $2. Press any key to exit..." _
    exit 1
}
trap 'handle_error $LINENO $?' ERR

# Ask for ref if not provided
if [[ -z "$VAULT_VERSION" ]]; then
  read -rp "Input a git ref (commit hash, branch name, tag name, 'master'): " input
  VAULT_VERSION="$input"
fi

VAULT_FOLDER=web-vault
OUTPUT_FOLDER=builds
OUTPUT_NAME="$OUTPUT_FOLDER/bw_web_$VAULT_VERSION.tar.gz"

npm install npm@7

mkdir -p "$OUTPUT_FOLDER"

# If this is the first time, clone the project
if [ ! -d "$VAULT_FOLDER" ]; then
    git clone https://github.com/bitwarden/web.git "$VAULT_FOLDER"
fi

cd $VAULT_FOLDER

# Clean
git checkout -f

# Update branch
git fetch --tags --all
git pull origin master

# Checkput the branch we want
git checkout "$VAULT_VERSION"
git submodule update --recursive --init

## How to create patches
# git --no-pager diff --submodule=diff --no-color --minimal > changes.patch
## How to apply patches
# git apply changes.patch
. ../apply_patches.sh

# Build
npm ci --legacy-peer-deps
npm audit fix --legacy-peer-deps || true
npm run dist:oss:selfhost

# Delete debugging map files, optional
#find build -name "*.map" -delete

# Create bwrs-version.json with the latest tag from the remote repo.
printf '{"version":"%s"}' \
      "$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' https://github.com/dani-garcia/bw_web_builds.git 'v*' | tail -n1 | sed -E 's#.*?refs/tags/v##')" \
      > build/vw-version.json

# Prepare the final archives
mv build web-vault
tar -czvf "../$OUTPUT_NAME" web-vault --owner=0 --group=0
mv web-vault build
