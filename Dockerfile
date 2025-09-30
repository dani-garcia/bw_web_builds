# syntax=docker/dockerfile:1

# Compile the web vault using docker
# Usage:
#    Quick and easy:
#    `make container-extract`
#    or, if you just want to build
#    `make container`
#    The default is to use `docker` you can also configure `podman` via a `.env` file
#    See the `.env.template` file for more details
#
#    docker build -t web_vault_build .
#    docker create --name bw_web_vault_extract web_vault_build
#    docker cp bw_web_vault_extract:/bw_web_vault.tar.gz .
#    docker rm bw_web_vault_extract
#
#    Note: you can use --build-arg to specify the version to build:
#    docker build -t web_vault_build --build-arg VAULT_VERSION=main .

FROM node:22-trixie AS build
RUN node --version && npm --version

# Can be a tag, release, but prefer a commit hash because it's not changeable
# https://github.com/bitwarden/clients/commit/${VAULT_VERSION}
#
# Using https://github.com/vaultwarden/vw_web_builds/tree/v2025.9.0
ARG VAULT_VERSION=c92f8621b16b42aec09afd72475f0f9391e6ad81
ENV VAULT_VERSION=$VAULT_VERSION
ENV VAULT_FOLDER=bw_clients
ENV CHECKOUT_TAGS=false

RUN mkdir /bw_web_builds
WORKDIR /bw_web_builds

COPY scripts ./scripts
# Use a glob pattern here so builds will continue even if the `.build_env` does not exists
COPY .build_env* ./

RUN ./scripts/checkout_web_vault.sh
RUN ./scripts/build_web_vault.sh
RUN mv "${VAULT_FOLDER}/apps/web/build" ./web-vault

RUN tar -czvf "bw_web_vault.tar.gz" web-vault --owner=0 --group=0
# Output the sha256sum here so people are able to match the sha256sum from the CI with the assets and the downloaded version if needed
RUN echo "sha256sum: $(sha256sum bw_web_vault.tar.gz)"

# We copy the final result as a separate empty image so there's no need to download all the intermediate steps
# The result is included both uncompressed and as a tar.gz, to be able to use it in the docker images and the github releases directly
FROM scratch
# hadolint ignore=DL3010
COPY --from=build /bw_web_builds/bw_web_vault.tar.gz /bw_web_vault.tar.gz
COPY --from=build /bw_web_builds/web-vault /web-vault

# Added so docker create works, can't actually run a scratch image
CMD [""]
