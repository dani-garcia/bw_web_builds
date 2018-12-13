#!/bin/bash

# Error handling
handle_error() {
    read -n1 -r -p "FAILED: line $1, exit code $2. Press any key to exit..." key
    exit 1
}
trap 'handle_error $LINENO $?' ERR

# Ask for ref if not provided
if [[ -z $WEB_REF ]]; then
  read -p "Input a git ref (commit hash, branch name, tag name, 'master'): " input
  WEB_REF=$input
fi

# If a patch was not provided, try to choose one
if [[ -z $PATCH_NAME ]]; then
    # If a patch with the same name as the ref exists, use it
    if [ -f patches/$WEB_REF.patch ]; then
        echo "Patch file found, using that"
        PATCH_NAME=$WEB_REF".patch"
    else
        echo "Patch file not found, using latest"
        # If not, use the latest one
        PATCH_NAME=$(ls patches | sort -V | tail -n1)
    fi
fi

echo "Building git ref: " $WEB_REF
echo "Using patch: " $PATCH_NAME

# If this is the first time, clone the project
if [ ! -d src ]; then
    git clone https://github.com/bitwarden/web.git src
fi

cd src

# Clean
git checkout .
git submodule foreach --recursive git checkout .

# Update branch
git fetch --tags
git pull origin master

# Checkput the branch we want
git checkout $WEB_REF

# Update submodule
npm run sub:update

## How to create patches
# git --no-pager diff --minimal > changes.patch
## How to apply patches
# git apply changes.patch

git apply ../patches/$PATCH_NAME

# Build
npm install
npm run dist

# Delete debugging map files, optional
find build -name "*.map" -delete

# Prepare the final archives
cd build
tar -czvf ../../bw_web_$WEB_REF.tar.gz *
