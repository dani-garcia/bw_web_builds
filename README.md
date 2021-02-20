# Bitwarden_rs web vault builds

[![GitHub Release](https://img.shields.io/github/release/dani-garcia/bw_web_builds.svg)](https://github.com/dani-garcia/bw_web_builds/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/bitwardenrs/web-vault.svg)](https://hub.docker.com/r/bitwardenrs/web-vault)
[![GPL-3.0 Licensed](https://img.shields.io/github/license/dani-garcia/bw_web_builds.svg)](https://github.com/dani-garcia/bw_web_builds/blob/master/LICENSE.txt)
[![Matrix Chat](https://img.shields.io/matrix/bitwarden_rs:matrix.org.svg?logo=matrix)](https://matrix.to/#/#bitwarden_rs:matrix.org)

This is a repository to store the builds of the [Bitwarden web vault](https://github.com/bitwarden/web) with the patches to make it work with [bitwarden_rs](https://github.com/dani-garcia/bitwarden_rs)

To create a patch you need to modify the original sources from [Bitwarden web vault](https://github.com/bitwarden/web) and execute:

```bash
git diff --submodule=diff
```

This is needed because there are patches within the jslib submodule which with a default `git diff` are not shown.

For more information see: [Install the web-vault](https://github.com/dani-garcia/bitwarden_rs/wiki/Building-binary#install-the-web-vault)

The builds are available in the [releases page](https://github.com/dani-garcia/bw_web_builds/releases), and can be replicated with the scripts in this repo.

_*Note, that this project is not associated with the [Bitwarden](https://bitwarden.com/) project nor 8bit Solutions LLC._
