#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
yum install -y pcre pcre-devel openssl-devel java-1.8.0-openjdk-devel cmake3 wget xz-devel freetype-devel

bash "${DIR}/gettext_install.sh"