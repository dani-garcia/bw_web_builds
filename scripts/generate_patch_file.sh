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

pushd "${VAULT_FOLDER}"

VAULT_VERSION=$(get_web_vault_version)
# Check if the vault versions starts with 20 and isn't a 40 char hash
if [[ ${VAULT_VERSION} = 20* ]] && [ ${#VAULT_VERSION} -ne 40 ]; then
    VAULT_VERSION="v${VAULT_VERSION}"
fi
PATCH_FILENAME="${VAULT_VERSION}.patch"

if [ "$(git status --porcelain | wc -l)" -ge 1 ]; then
    git --no-pager diff --submodule=diff --no-color --minimal > "../patches/${PATCH_FILENAME}"
    echo "Patch has been created here: patches/${PATCH_FILENAME}"
else
    echo "No changes found, skip generating a patch file."
fi

popd
