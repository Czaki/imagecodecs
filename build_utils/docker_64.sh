#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "${DIR}"
docker build -t imagecodecs_manylinux2010_x86_64 . && docker run imagecodecs_manylinux2010_x86_64