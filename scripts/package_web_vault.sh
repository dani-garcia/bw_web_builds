#!/usr/bin/env bash
set -o pipefail -o errexit
BASEDIR=$(RL=$(readlink -n "$0"); SP="${RL:-$0}"; dirname "$(cd "$(dirname "${SP}")"; pwd)/$(basename "${SP}")")

# Error handling
handle_error() {
    read -n1 -r -p "FAILED: line $1, exit code $2. Press any key to exit..." _
    exit 1
}
trap 'handle_error $LINENO $?' ERR

# This script now calls all other scripts and will do the exact same as it did before.
# The only change is that all parts are split-up so they can run separately

# Load default script environment variables
# shellcheck source=.script_env
. "${BASEDIR}/.script_env"

# Checkout the web-vault from github
# shellcheck source=checkout_web_vault.sh
. "${BASEDIR}/checkout_web_vault.sh"

# Patch the web-vault using our patches
# shellcheck source=patch_web_vault.sh
. "${BASEDIR}/patch_web_vault.sh"

# Build the web-vault using node and npm
# shellcheck source=build_web_vault.sh
. "${BASEDIR}/build_web_vault.sh"

# Generate an archive from the build
# shellcheck source=tar_web_vault.sh
. "${BASEDIR}/tar_web_vault.sh"
