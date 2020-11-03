#!/bin/bash
set -o pipefail -o errexit

# If a patch was not provided, try to choose one
if [[ -z $PATCH_NAME ]]; then
    # If a patch with the same name as the ref exists, use it
    if [ -f "../patches/$VAULT_VERSION.patch" ]; then
        echo "Patch file found, using that"
        PATCH_NAME="$VAULT_VERSION.patch"
    else
        echo "Patch file not found, using latest"
        # If not, use the latest one
        PATCH_NAME="$(find ../patches -printf "%f\\n" | sort -V | tail -n1)"
    fi
fi

echo "Using patch: $PATCH_NAME"
git apply "../patches/$PATCH_NAME"
cd ./jslib
git apply "/jslib_patches/jslib_email.patch"
echo "Patching successful!"
