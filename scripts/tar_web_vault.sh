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
OUTPUT_NAME="${BASEDIR}/../${OUTPUT_FOLDER}/bw_web_${VAULT_VERSION}"
DATE_FORMAT="${DATE_FORMAT:-%Y-%m-%dT%H:%M:%S%z}"

# Preserve previous output
if [[ -f "${OUTPUT_NAME}.tar.gz" ]];
then
    DATE_SUFFIX=$(date +"${DATE_FORMAT}" -r "${OUTPUT_NAME}.tar.gz")
    mv "${OUTPUT_NAME}.tar.gz" "${OUTPUT_NAME}_${DATE_SUFFIX}.tar.gz"
fi

# Cleanup previous output directory
if [[ -d "${OUTPUT_NAME}" ]];
then
    rm -rf "${OUTPUT_NAME}"
fi

mv build web-vault
# Tar the web-vault
tar -czvf "${OUTPUT_NAME}.tar.gz" web-vault --owner=0 --group=0

# Copy the web-vault
cp -dpr web-vault "${OUTPUT_NAME}"
mv web-vault build

popd
