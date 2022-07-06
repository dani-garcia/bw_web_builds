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

if [ ! -d "${VAULT_FOLDER}" ]; then
    # If this is the first time, clone the project
    git clone https://github.com/bitwarden/clients.git "${VAULT_FOLDER}"
else
    # If there already is a checked-out repo, lets clean it up first.
    pushd "${VAULT_FOLDER}"
        # Stash current changes if there are any, we don't want to loose our work if we had some
        git stash --all --quiet &> /dev/null || true
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
