#!/bin/bash

set -ex

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
VERSION_FILE="${SCRIPT_DIR}/../VERSION"
VERSION=$(head $VERSION_FILE)

DOCKER_IMAGE_BASE="docker.elastic.co"
BASE_IMAGE_TAG="data-extraction-service:${VERSION}"
BASE_IMAGE_TAG_FINAL="$DOCKER_IMAGE_BASE/$BASE_IMAGE_TAG"

echo "Building the docker image..."
docker build -t "$BASE_IMAGE_TAG_FINAL" -f Dockerfile .

echo "Logging into docker..."
/bin/bash "${SCRIPT_DIR}/docker-login.sh"

echo "Publishing the docker image..."
docker push "$BASE_IMAGE_TAG_FINAL"
