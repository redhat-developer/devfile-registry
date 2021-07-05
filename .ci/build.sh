#!/usr/bin/env bash
# This script downloads the registry build tools and builds up this repository
# This script runs on both the GitHub action CI and the CICD for the hosted registry

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker build --no-cache -t devfile-index -f $ABSOLUTE_PATH/Dockerfile $ABSOLUTE_PATH/..
