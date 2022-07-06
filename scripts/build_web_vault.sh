#!/usr/bin/env bash
set -o pipefail -o errexit
BASEDIR=$(dirname "$(readlink -f "$0")")

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
npm audit fix || true

pushd apps/web
npm run dist:oss:selfhost

# Delete debugging map files, optional
#find build -name "*.map" -delete

# Create vw-version.json with the latest tag from the remote repo.
printf '{"version":"%s"}' \
      "$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' https://github.com/dani-garcia/bw_web_builds.git 'v*' | tail -n1 | sed -E 's#.*?refs/tags/v##')" \
      > build/vw-version.json

popd
popd
