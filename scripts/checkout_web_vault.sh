#!/usr/bin/env bash
set -o pipefail -o errexit
BASEDIR=$(RL=$(readlink -n "$0"); SP="${RL:-$0}"; dirname "$(cd "$(dirname "${SP}")"; pwd)/$(basename "${SP}")")

FALLBACK_WEBVAULT_VERSION=v2025.8.0

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
    read -rp "Input a git ref (commit hash, branch name, tag name, '${FALLBACK_WEBVAULT_VERSION}'): " input
    VAULT_VERSION="${input:-${FALLBACK_WEBVAULT_VERSION}}"
fi

# Check the format of the provided vault version
# If this is vYYYY.M.B or YYYY.M.B then fix this automatically to prepend `v`
if [[ "${VAULT_VERSION}" =~ ^20[0-9]{2}\.[0-9]{1,2}.[0-9]{1} ]]; then
    VAULT_VERSION="v${VAULT_VERSION}"
fi

echo "Using: '${VAULT_VERSION}' to checkout bitwarden/client."

if [ ! -d "${VAULT_FOLDER}" ]; then
    mkdir -pv "${VAULT_FOLDER}"
    pushd "${VAULT_FOLDER}"
        # If this is the first time, init the repo and checkout the requested branch/tag/hash
        git -c init.defaultBranch=main init
        git remote add vaultwarden https://github.com/vaultwarden/vw_web_builds.git
    popd
else
    # If there already is a checked-out repo, lets clean it up first.
    pushd "${VAULT_FOLDER}"
        # Stash current changes if there are any, we don't want to lose our work if we had some
        echo "Stashing all custom changes"
        git stash --include-untracked --quiet &> /dev/null || true

        # Reset hard to make sure no changes are left
        git reset --hard

        VAULTWARDEN_REMOTE=$(git remote get-url vaultwarden || echo -n )
        if [ "x${VAULTWARDEN_REMOTE}" = "x" ]
	then
           echo "adding vaultwarden/vw_web_builds as remote repository"
           git remote add vaultwarden https://github.com/vaultwarden/vw_web_builds.git
        elif [ "${VAULTWARDEN_REMOTE}" != "https://github.com/vaultwarden/vw_web_builds.git" ]
	then
            echo "Warning: \`git remote get vaultwarden\` did not return the expected repository"
	    echo "expected: https://github.com/vaultwarden/vw_web_builds.git"
	    echo "received: ${VAULTWARDEN_REMOTE}"
	    read -p "Press enter to continue"
        fi
    popd
fi

if [[ "$CHECKOUT_TAGS" == "true" ]]; then
    CHECKOUT_ARGS="${CHECKOUT_ARGS:-} --tags"
fi

# Checkout the request
pushd "${VAULT_FOLDER}"
    # Update branch and tag metadata
    git fetch --depth 1 ${CHECKOUT_ARGS:-} vaultwarden "${VAULT_VERSION}"
    # Checkout the branch we want
    git -c advice.detachedHead=false checkout "${VAULT_VERSION}"
popd
