#!/bin/bash
#
# Build the Docker image, optionally publishing it.
# Usage: build-and-publish-docker-image.sh [--push]
#

set -ex

PUSH=false
if [[ "$1" == "--push" ]]; then
  PUSH=true
fi

if [[ "$PUSH" == "true" ]]; then
  VAULT_ADDR=${VAULT_ADDR:-https://vault-ci-prod.elastic.dev}
  VAULT_USER="docker-swiftypeadmin"
  echo "Fetching Docker credentials for '$VAULT_USER' from Vault..."
  DOCKER_USER=$(vault read -address "${VAULT_ADDR}" -field user_20230609 secret/ci/elastic-data-extraction-service/${VAULT_USER})

  echo "Logging into docker..."
  vault read -address "${VAULT_ADDR}" -field secret_20230609 secret/ci/elastic-data-extraction-service/${VAULT_USER} | \
    buildah login --username="${DOCKER_USER}" --password-stdin docker.elastic.co

  echo "Building and publishing the docker image..."
  drivah build --push .
else
  echo "Building the docker image..."
  drivah build .
fi
