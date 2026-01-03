# Web Vault builds for Vaultwarden

![Vaultwarden Logo](https://raw.githubusercontent.com/vaultwarden/vaultwarden/refs/heads/main/resources/vaultwarden-logo-auto.svg)

Scripts and CI to patch (including branding) and build the [Bitwarden web client](https://github.com/bitwarden/clients/tree/main/apps/web) [[disclaimer](#disclaimer)], to make it compatible with [Vaultwarden](https://github.com/vaultwarden/vaultwarden).

---

[![GitHub Release](https://img.shields.io/github/release/vaultwarden/bw_web_builds.svg?style=for-the-badge&logo=vaultwarden&color=005AA4)](https://github.com/vaultwarden/bw_web_builds/releases/latest)
[![ghcr.io Pulls](https://img.shields.io/badge/dynamic/json?style=for-the-badge&logo=github&logoColor=fff&color=005AA4&url=https%3A%2F%2Fipitio.github.io%2Fbackage%2Fvaultwarden%2Fbw_web_builds%2Fbw_web_builds.json&query=%24.downloads&label=ghcr.io%20pulls&cacheSeconds=14400)](https://github.com/vaultwarden/bw_web_builds/pkgs/container/bw_web_builds)
[![Docker Pulls](https://img.shields.io/docker/pulls/vaultwarden/web-vault.svg?style=for-the-badge&logo=docker&logoColor=fff&color=005AA4&label=docker.io%20pulls)](https://hub.docker.com/r/vaultwarden/web-vault) <br>
[![GHA Release](https://img.shields.io/github/actions/workflow/status/vaultwarden/bw_web_builds/release.yml?style=flat-square&logo=github&logoColor=fff&label=Build%20Workflow)](https://github.com/vaultwarden/bw_web_builds/actions/workflows/release.yml)
[![Contributors](https://img.shields.io/github/contributors-anon/vaultwarden/bw_web_builds.svg?style=flat-square&logo=vaultwarden&color=005AA4)](https://github.com/vaultwarden/bw_web_builds/graphs/contributors)
[![Forks](https://img.shields.io/github/forks/vaultwarden/bw_web_builds.svg?style=flat-square&logo=github&logoColor=fff&color=005AA4)](https://github.com/vaultwarden/bw_web_builds/network/members)
[![Stars](https://img.shields.io/github/stars/vaultwarden/bw_web_builds.svg?style=flat-square&logo=github&logoColor=fff&color=005AA4)](https://github.com/vaultwarden/bw_web_builds/stargazers)
[![Issues Open](https://img.shields.io/github/issues/vaultwarden/bw_web_builds.svg?style=flat-square&logo=github&logoColor=fff&color=005AA4&cacheSeconds=300)](https://github.com/vaultwarden/bw_web_builds/issues)
[![Issues Closed](https://img.shields.io/github/issues-closed/vaultwarden/bw_web_builds.svg?style=flat-square&logo=github&logoColor=fff&color=005AA4&cacheSeconds=300)](https://github.com/vaultwarden/bw_web_builds/issues?q=is%3Aissue+is%3Aclosed) <br>
[![Matrix Chat](https://img.shields.io/matrix/vaultwarden:matrix.org.svg?style=flat-square&logo=matrix&logoColor=fff&color=953B00&cacheSeconds=14400)](https://matrix.to/#/#vaultwarden:matrix.org)
[![GitHub Discussions](https://img.shields.io/github/discussions/vaultwarden/vaultwarden?style=flat-square&logo=github&logoColor=fff&color=953B00&cacheSeconds=300)](https://github.com/vaultwarden/vaultwarden/discussions)
[![Discourse Discussions](https://img.shields.io/discourse/topics?server=https%3A%2F%2Fvaultwarden.discourse.group%2F&style=flat-square&logo=discourse&color=953B00)](https://vaultwarden.discourse.group/)
[![GPL-3.0 Licensed](https://img.shields.io/github/license/vaultwarden/bw_web_builds.svg?style=flat-square&logo=vaultwarden&color=944000&cacheSeconds=14400)](https://github.com/vaultwarden/bw_web_builds/blob/main/LICENSE.txt)


> [!IMPORTANT]
> **When using this web-vault, please report any bugs or suggestions directly to us (see [Get in touch](#get-in-touch)), regardless of whatever other clients you are using (mobile, desktop, browser...). DO NOT use the official Bitwarden support channels.**

---

## Building the web-vault

To build the web-vault you need either node and npm installed or use Docker.

### Using node and npm

For a quick and easy local build you could run:
```bash
make full
```

That will generate a `tar.gz` file within the `builds` directory which you can extract and use with the `WEB_VAULT_FOLDER` environment variable.

### Using a container

Or via the usage of building via a container:
```bash
make container-extract
```

That will extract the `tar.gz` and files generated via Docker into the `container_builds` directory.

#### Which container command to use, docker or podman

The default is to use `docker`, but `podman` works too.

You can force them by replacing `container` with either `docker` or `podman`, like:
```bash
make docker-extract
# Or
make podman-extract
```

You can configure the default via a `.env` file. See the `.env.template`.<br>
Or you can set it as a make argument with the make command:
```bash
make CONTAINER_CMD=podman container-extract
```

### More information
For more information see: [Install the web-vault](https://github.com/vaultwarden/vaultwarden/wiki/Building-binary#install-the-web-vault)

### Pre-build
The builds are available in the [releases page](https://github.com/vaultwarden/bw_web_builds/releases), and can be replicated with the scripts in this repo.

<br>

## Get in touch
If you spot any bugs or crashes with Vaultwarden itself, please [create an issue here](https://github.com/vaultwarden/vaultwarden/issues/). Make sure there aren't any similar issues open, though!

To ask a question, offer suggestions or new features or to get help configuring or installing the software, please use either [GitHub Discussions](https://github.com/vaultwarden/vaultwarden/discussions) or [the forum](https://vaultwarden.discourse.group/).

If you prefer to chat, we're usually hanging around at [#vaultwarden:matrix.org](https://matrix.to/#/#vaultwarden:matrix.org) room on Matrix. Feel free to join us!
