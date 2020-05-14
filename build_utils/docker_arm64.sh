#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "${DIR}"
docker build -f Dockerfile_arm64 -t bokota/imagecodecs_arm64:2020.1.31 .