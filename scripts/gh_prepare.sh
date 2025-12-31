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

# Ask for release tag if not provided
if [[ -z "$RELEASE_TAG" ]]; then
    read -rp "Provide git release tag (example: v2023.12.0): " input
    RELEASE_TAG="${input}"
fi

# Check if the RELEASE_TAG starts with vYYYY.M.B and patch letters are allowed like vYYYY.M.Ba
if [[ ! "${RELEASE_TAG}" =~ ^v20[0-9]{2}\.[0-9]{1,2}.[0-9]{1}(\+[1-9][0-9]*)?$ ]]; then
    echo "The provided release tag does not meet our standards!"
    echo "'${RELEASE_TAG}' does not match the vYYYY.M.B format."
    exit 1
fi

# Verify if the input is correct
while true; do
    read -rp "Using: '${RELEASE_TAG}' as tag, continue? (y/n): " yn
    case $yn in
        [Yy] )
            # Continue with the release
            break
            ;;
        [Nn] )
            echo "Aborting release"
            exit 1
            ;;
        * ) echo "Please answer y or n"
            ;;
    esac
done

git tag -s "${RELEASE_TAG}"
git push origin "${RELEASE_TAG}"
echo "Wait a few seconds before using gh to create a draft release"
sleep 5
gh release create "${RELEASE_TAG}" --generate-notes --draft

echo "Now wait for the container to be build and pushed before running 'make gh-release'"
