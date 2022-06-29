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

mkdir -pv "${BASEDIR}/../${OUTPUT_FOLDER}"

pushd "${VAULT_FOLDER}/apps/web"

VAULT_VERSION=$(get_web_vault_version)
OUTPUT_NAME="${OUTPUT_FOLDER}/bw_web_${VAULT_VERSION}"

mv build web-vault
# Tar the web-vault
tar -czvf "${BASEDIR}/../${OUTPUT_NAME}.tar.gz" web-vault --owner=0 --group=0
# Copy the web-vault
cp -dpr web-vault "${BASEDIR}/../${OUTPUT_NAME}"
mv web-vault build

popd
