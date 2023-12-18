# Web Vault builds for Vaultwarden

[![GitHub Release](https://img.shields.io/github/release/dani-garcia/bw_web_builds.svg)](https://github.com/dani-garcia/bw_web_builds/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/vaultwarden/web-vault.svg)](https://hub.docker.com/r/vaultwarden/web-vault)
[![GPL-3.0 Licensed](https://img.shields.io/github/license/dani-garcia/bw_web_builds.svg)](https://github.com/dani-garcia/bw_web_builds/blob/master/LICENSE.txt)
[![Matrix Chat](https://img.shields.io/matrix/vaultwarden:matrix.org.svg?logo=matrix)](https://matrix.to/#/#vaultwarden:matrix.org)

**This project is not associated with the [Bitwarden](https://bitwarden.com/) project nor Bitwarden, Inc.**

#### ⚠️**IMPORTANT**⚠️: When using this server, please report any bugs or suggestions to us directly (look at the bottom of this page for ways to get in touch), regardless of whatever clients you are using (mobile, desktop, browser...). DO NOT use the official support channels.

---

<br>

This is a repository to store the builds of the [Bitwarden web vault](https://github.com/bitwarden/clients/tree/main/apps/web) with the patches to make it work with [Vaultwarden](https://github.com/dani-garcia/vaultwarden)

To create a patch you need to modify the original sources from [Bitwarden web vault](https://github.com/bitwarden/clients/tree/main/apps/web) and execute:

```bash
git --no-pager diff --submodule=diff --no-color --minimal
```

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
For more information see: [Install the web-vault](https://github.com/dani-garcia/vaultwarden/wiki/Building-binary#install-the-web-vault)

### Pre-build
The builds are available in the [releases page](https://github.com/dani-garcia/bw_web_builds/releases), and can be replicated with the scripts in this repo.

<br>

## Get in touch
If you spot any bugs or crashes with Vaultwarden itself, please [create an issue here](https://github.com/dani-garcia/vaultwarden/issues/). Make sure there aren't any similar issues open, though!

To ask a question, offer suggestions or new features or to get help configuring or installing the software, please use either [GitHub Discussions](https://github.com/dani-garcia/vaultwarden/discussions) or [the forum](https://vaultwarden.discourse.group/).

If you prefer to chat, we're usually hanging around at [#vaultwarden:matrix.org](https://matrix.to/#/#vaultwarden:matrix.org) room on Matrix. Feel free to join us!
