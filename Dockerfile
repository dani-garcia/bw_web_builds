# Compile the web vault using docker
# Usage:
#    docker build -t web_vault_build .
#    image_id=$(docker create web_vault_build)
#    docker cp $image_id:/bw_web_vault.tar.gz .
#    docker rm $image_id
#
#    Note: you can use --build-arg to specify the version to build:
#    docker build -t web_vault_build --build-arg VAULT_VERSION=master .

#    image_id=$(docker create bitwardenrs/web-vault@sha256:feb3f46d15738191b9043be4cdb1be2c0078ed411e7b7be73a2f4fcbca01e13c)
#    docker cp $image_id:/bw_web_vault.tar.gz .
#    docker rm $image_id

FROM node:14.16.0-buster as build

# Prepare the folder to enable non-root, otherwise npm will refuse to run the postinstall
RUN mkdir /vault
RUN chown node:node /vault
USER node

# Can be a tag, release, but prefer a commit hash because it's not changeable
# https://github.com/bitwarden/web/commit/$VAULT_VERSION
#
# Using https://github.com/bitwarden/web/releases/tag/v2.20.1
ARG VAULT_VERSION=165944624a5edb1b1d1b4047ccdeb04c2d07c7d6

RUN git clone https://github.com/bitwarden/web.git /vault
WORKDIR /vault

RUN git checkout "$VAULT_VERSION"
RUN git submodule update --recursive --init

COPY --chown=node:node patches /patches
COPY --chown=node:node apply_patches.sh /apply_patches.sh

RUN bash /apply_patches.sh

# Build
RUN npm install
RUN npm audit fix
RUN npm run dist

RUN printf '{"version":"%s"}' \
      $(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' https://github.com/dani-garcia/bw_web_builds.git 'v*' | tail -n1 | sed -E 's#.*?refs/tags/v##') \
      > build/bwrs-version.json

# Delete debugging map files, optional
# RUN find build -name "*.map" -delete

# Prepare the final archives
RUN mv build web-vault
RUN tar -czvf "bw_web_vault.tar.gz" web-vault --owner=0 --group=0

# We copy the final result as a separate empty image so there's no need to download all the intermediate steps
# The result is included both uncompressed and as a tar.gz, to be able to use it in the docker images and the github releases directly
FROM scratch
COPY --from=build /vault/bw_web_vault.tar.gz /bw_web_vault.tar.gz
COPY --from=build /vault/web-vault /web-vault
# Added so docker create works, can't actually run a scratch image
CMD [""]
