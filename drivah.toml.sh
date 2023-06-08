#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
VERSION_FILE="${SCRIPT_DIR}/VERSION"
VERSION=$(head $VERSION_FILE)

DOCKER_REPO="docker.elastic.co"
DOCKER_NAMESPACE="swiftype"
DOCKER_PROJECT_NAME="data-extraction-service"
DOCKER_IMAGE_BASE="${DOCKER_REPO}/${DOCKER_NAMESPACE}/${DOCKER_PROJECT_NAME}"


cat <<EOF
[container.image]
names = ["${DOCKER_IMAGE_BASE}"]
tags = ["${VERSION}"]
EOF