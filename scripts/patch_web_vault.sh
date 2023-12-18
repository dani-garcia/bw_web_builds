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

pushd "${VAULT_FOLDER}"

# Try to get the vault version if possible
if [[ -z ${VAULT_VERSION} ]]; then
    VAULT_VERSION=$(get_web_vault_version)
fi

# Check the format of the provided vault version
# If this is web-vYYYY.M.B or YYYY.M.B then fix this automatically to prepend with a `v` or remove web
if [[ "${VAULT_VERSION}" =~ ^20[0-9]{2}\.[0-9]{1,2}.[0-9]{1} ]]; then
    VAULT_VERSION="v${VAULT_VERSION}"
elif [[ "${VAULT_VERSION}" =~ ^web-v20[0-9]{2}\.[0-9]{1,2}.[0-9]{1} ]]; then
    VAULT_VERSION="${VAULT_VERSION#web-}"
fi

export VAULT_VERSION

# Apply a patch from the patches directory
# shellcheck source=apply_patches.sh
. "${BASEDIR}/apply_patches.sh"

popd
