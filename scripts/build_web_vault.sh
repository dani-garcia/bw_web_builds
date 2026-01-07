#!/usr/bin/env bash
set -o pipefail -o errexit
BASEDIR=$(RL=$(readlink -n "$0"); SP="${RL:-$0}"; dirname "$(cd "$(dirname "${SP}")"; pwd)/$(basename "${SP}")")

# Error handling
handle_error() {
    read -n1 -r -p "FAILED: line $1, exit code $2. Press any key to exit..." _
    exit 1
}
trap 'handle_error $LINENO $?' ERR

# Load default script environment variables
# shellcheck source=.script_env
. "${BASEDIR}/.script_env"

# Show used versions
node --version
npm --version

# Build
pushd "${VAULT_FOLDER}"
npm ci

pushd apps/web
npm run dist:oss:selfhost

# Delete debugging map files, optional
#find build -name "*.map" -delete

# Create vw-version.json with the latest tag from the remote repo.
printf '{"version":"%s"}' \
      "$(git -c 'versionsort.suffix=-' ls-remote --tags --refs --sort=creatordate https://github.com/dani-garcia/bw_web_builds.git 'v*' | tail -n1 | grep -Eo '[^\/v]*$')" \
      > build/vw-version.json

popd
popd
