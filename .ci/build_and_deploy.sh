#!/usr/bin/env bash
# This script downloads the registry build tools and builds up this repository then pushes it to quay.io
# This will be run via the app-sre CI.
set -ex
ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_REV="$(git rev-parse --short=7 HEAD)"
INDEX_IMAGE="${INDEX_IMAGE:-quay.io/app-sre/redhat-devfile-index}"
VIEWER_IMAGE="${VIEWER_IMAGE:-quay.io/app-sre/redhat-registry-viewer}"
IMAGE_TAG="${IMAGE_TAG:-${GIT_REV}}"

# Run the build script
$ABSOLUTE_PATH/build.sh

# Clone devfile-web for building registry-viewer
if [ -d $ABSOLUTE_PATH/devfile-web ]
then
    rm -rf $ABSOLUTE_PATH/devfile-web
fi
git clone https://github.com/devfile/devfile-web.git $ABSOLUTE_PATH/devfile-web

# Build registry-viewer
bash $ABSOLUTE_PATH/devfile-web/scripts/build_viewer.sh

# Push the iamge to quay.io
if [[ -n "$QUAY_USER" && -n "$QUAY_TOKEN" ]]; then
    DOCKER_CONF="$PWD/.docker"
    mkdir -p "$DOCKER_CONF"

    # login into quay.io
    docker --config="$DOCKER_CONF" login -u="$QUAY_USER" -p="$QUAY_TOKEN" quay.io

    # devfile-index
    docker tag devfile-index "${INDEX_IMAGE}:${IMAGE_TAG}"
    docker tag devfile-index "${INDEX_IMAGE}:next"
    docker --config="$DOCKER_CONF" push "${INDEX_IMAGE}:${IMAGE_TAG}"
    docker --config="$DOCKER_CONF" push "${INDEX_IMAGE}:next"

    # registry-viewer
    docker tag registry-viewer "${VIEWER_IMAGE}:${IMAGE_TAG}"
    docker tag registry-viewer "${VIEWER_IMAGE}:next"
    docker --config="$DOCKER_CONF" push "${VIEWER_IMAGE}:${IMAGE_TAG}"
    docker --config="$DOCKER_CONF" push "${VIEWER_IMAGE}:next"
fi
