#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
VERSION_FILE="${SCRIPT_DIR}/VERSION"
VERSION=$(head $VERSION_FILE)

DOCKER_REPO="docker.elastic.co"

DOCKER_NAMESPACE="integrations"
DOCKER_PROJECT_NAME="data-extraction-service"
DOCKER_IMAGE_BASE="${DOCKER_REPO}/${DOCKER_NAMESPACE}/${DOCKER_PROJECT_NAME}"

# We will continue to build and push image to namespace enterprise-search in 8.16 and 8.17
TEMP_DOCKER_NAMESPACE="enterprise-search"
TEMP_DOCKER_IMAGE_BASE="${DOCKER_REPO}/${TEMP_DOCKER_NAMESPACE}/${DOCKER_PROJECT_NAME}"

cat <<EOF
[container.image]
names = ["${DOCKER_IMAGE_BASE}", "${TEMP_DOCKER_IMAGE_BASE}"]
tags = ["${VERSION}"]
EOF