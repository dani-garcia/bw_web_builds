#!/bin/bash

export UPLOAD_VAULT="n"

export WEB_REF="v2.5.0"
bash package_web_vault.sh

export WEB_REF="v2.6.0"
bash package_web_vault.sh

export WEB_REF="v2.6.1"
bash package_web_vault.sh

export WEB_REF="v2.7.0"
bash package_web_vault.sh

export WEB_REF="v2.7.1"
bash package_web_vault.sh

export WEB_REF="v2.8.0"
bash package_web_vault.sh
