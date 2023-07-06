#!/bin/bash

set -ex

source scripts/git-setup.sh

VAULT_ADDR=${VAULT_ADDR:-https://vault-ci-prod.elastic.dev}
VAULT_USER="docker-swiftypeadmin"
echo "Fetching Docker credentials for '$VAULT_USER' from Vault..."
DOCKER_USER=$(vault read -address "${VAULT_ADDR}" -field user_20230609 secret/ci/elastic-data-extraction-service/${VAULT_USER})

echo "Logging into docker..."
vault read -address "${VAULT_ADDR}" -field secret_20230609 secret/ci/elastic-data-extraction-service/${VAULT_USER} | \
  buildah login --username="${DOCKER_USER}" --password-stdin docker.elastic.co

echo "Building and publishing the docker image..."
drivah build --push .
