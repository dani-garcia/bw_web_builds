#!/usr/bin/env bash
set -o pipefail -o errexit

# Error handling
handle_error() {
    read -n1 -r -p "FAILED: line $1, exit code $2. Press any key to exit..." _
    exit 1
}
trap 'handle_error $LINENO $?' ERR

if ! command -v gh >/dev/null 2>&1; then
    echo "gh command not found, unable te prepare a release."
    exit 1
fi

current_branch=$(git branch --show-current 2>/dev/null || git symbolic-ref --short HEAD 2>/dev/null)
if [[ -n "$current_branch" && "${current_branch}" != "master" ]]; then
    echo "Current branch '$current_branch' is not the 'master' branch."
    echo "Please checkout and pull the master branch before you continue."
    exit 1
fi

if [[ -z "$GPG_SIGNING_USER" ]]; then
    read -rp "Provide the GPG user or key which will sign the tar.gz file: " input
    GPG_SIGNING_USER="${input}"
fi

if [[ -n "$GPG_SIGNING_USER" ]]; then
    if ! gpg --list-keys "$GPG_SIGNING_USER" >/dev/null 2>&1; then
        echo "GPG Key for '${GPG_SIGNING_USER}' not found."
        exit 1
    fi
fi

# Get the latest release tag, this should match the tag created with `gh-prepare`
LATEST_REMOTE_TAG="v$(git -c 'versionsort.suffix=-' ls-remote --tags --refs --sort='v:refname' https://github.com/dani-garcia/bw_web_builds.git 'v*' | tail -n1 | grep -Eo '[^\/v]*$')"

# Ask for release tag if not provided, or validate the `$LATEST_REMOTE_TAG`
if [[ -z "$RELEASE_TAG" ]]; then
    read -rp "Provide git release tag (default: '${LATEST_REMOTE_TAG}'): " input
    RELEASE_TAG="${input:-${LATEST_REMOTE_TAG}}"
fi

# Check if the RELEASE_TAG starts with vYYYY.M.B and patch letters are allowed like vYYYY.M.Ba
if [[ ! "${RELEASE_TAG}" =~ ^v20[0-9]{2}\.[0-9]{1,2}.[0-9]{1}(\.[1-9][0-9]*)?$ ]]; then
    echo "The provided release tag does not meet our standards!"
    echo "'${RELEASE_TAG}' does not match the vYYYY.M.B(.P) format."
    exit 1
fi

while true; do
    read -rp "Using: '${RELEASE_TAG}' as tag, continue? (y/n): " yn
    case $yn in
        [Yy] )
            # Continue with the release
            break
            ;;
        [Nn] )
            echo "Aborting prepare"
            exit 1
            ;;
        * ) echo "Please answer y or n"
            ;;
    esac
done

echo "Extracting tar.gz file from GitHub Container Registry"
${CONTAINER_CMD} create --name "bw_web_${RELEASE_TAG}" "ghcr.io/dani-garcia/bw_web_builds:${RELEASE_TAG}"
${CONTAINER_CMD} cp "bw_web_${RELEASE_TAG}:/bw_web_vault.tar.gz" "bw_web_${RELEASE_TAG}.tar.gz"
${CONTAINER_CMD} rm "bw_web_${RELEASE_TAG}"

if [[ -f "bw_web_${RELEASE_TAG}.tar.gz" ]]; then
    gpg --yes --detach-sign --armor --local-user "$GPG_SIGNING_USER" --output "bw_web_${RELEASE_TAG}.tar.gz.asc" "bw_web_${RELEASE_TAG}.tar.gz"
    sha256sum "bw_web_${RELEASE_TAG}.tar.gz"* | tee sha256sums.txt

    gh release upload "${RELEASE_TAG}" "bw_web_${RELEASE_TAG}.tar.gz" "bw_web_${RELEASE_TAG}.tar.gz.asc" sha256sums.txt
    # gh release edit "${RELEASE_TAG}" --draft=false
fi
