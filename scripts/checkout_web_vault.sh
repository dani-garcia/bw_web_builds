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

# Ask for ref if not provided
if [[ -z "$VAULT_VERSION" ]]; then
    read -rp "Input a git ref (commit hash, branch name, tag name, 'main'): " input
    VAULT_VERSION="${input:-main}"
fi

# Check the format of the provided vault version
# If this is vYYYY.M.B or YYYY.M.B then fix this automatically to prepend web- or web-v
if [[ "${VAULT_VERSION}" =~ ^20[0-9]{2}\.[0-9]{1,2}.[0-9]{1} ]]; then
    VAULT_VERSION="web-v${VAULT_VERSION}"
elif [[ "${VAULT_VERSION}" =~ ^v20[0-9]{2}\.[0-9]{1,2}.[0-9]{1} ]]; then
    VAULT_VERSION="web-${VAULT_VERSION}"
fi

echo "Using: '${VAULT_VERSION}' to checkout bitwarden/client."

if [ ! -d "${VAULT_FOLDER}" ]; then
    mkdir -pv "${VAULT_FOLDER}"
    pushd "${VAULT_FOLDER}"
        # If this is the first time, init the repo and checkout the requested branch/tag/hash
        git -c init.defaultBranch=main init
        git remote add origin https://github.com/bitwarden/clients.git
    popd
else
    # If there already is a checked-out repo, lets clean it up first.
    pushd "${VAULT_FOLDER}"
        # Stash current changes if there are any, we don't want to lose our work if we had some
        echo "Stashing all custom changes"
        git stash --include-untracked --quiet &> /dev/null || true

        # Reset hard to make sure no changes are left
        git reset --hard
    popd
fi

if [[ "$CHECKOUT_TAGS" == "true" ]]; then
    CHECKOUT_ARGS="${CHECKOUT_ARGS:-} --tags"
fi

# Checkout the request
pushd "${VAULT_FOLDER}"
    # Update branch and tag metadata
    git fetch --depth 1 ${CHECKOUT_ARGS:-} origin "${VAULT_VERSION}"
    # Checkout the branch we want
    git -c advice.detachedHead=false checkout FETCH_HEAD
popd
