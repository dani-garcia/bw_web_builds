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

# Ask for ref if not provided
if [[ -z "$VAULT_VERSION" ]]; then
    read -rp "Input a git ref (commit hash, branch name, tag name, 'master'): " input
    VAULT_VERSION="${input}"
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
    # If this is the first time, clone the project
    git clone https://github.com/bitwarden/clients.git "${VAULT_FOLDER}"
else
    # If there already is a checked-out repo, lets clean it up first.
    pushd "${VAULT_FOLDER}"
        # Stash current changes if there are any, we don't want to loose our work if we had some
        git stash --include-untracked --quiet &> /dev/null || true
        # Checkout the master repo first
        git checkout master
        git reset --hard
        git checkout -f
    popd
fi

pushd "${VAULT_FOLDER}"

# Update branch and tag metadata
git fetch --tags --all
git pull origin master

# Checkout the branch we want
git -c advice.detachedHead=false checkout "${VAULT_VERSION}"

popd
