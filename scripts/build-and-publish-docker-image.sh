#!/bin/bash

# DO NOT SET -x
# This script fetches and assigns credentials to variables. -x would cause those creds to be printed in logs
set -e
# DO NOT SET -x

VAULT_ADDR=${VAULT_ADDR:-https://vault-ci-prod.elastic.dev}
VAULT_USER="docker-swiftypeadmin"
echo "Fetching Docker credentials for '$VAULT_USER' from Vault..."
DOCKER_USER=$(vault read -address "${VAULT_ADDR}" -field user_20230609 secret/ci/elastic-data-extraction-service/${VAULT_USER})
DOCKER_PASSWORD=$(vault read -address "${VAULT_ADDR}" -field secret_20230609 secret/ci/elastic-data-extraction-service/${VAULT_USER})

echo "Logging into docker..."
buildah login --username="${DOCKER_USER}" --password="${DOCKER_PASSWORD}" docker.elastic.co

echo "Building and publishing the docker image..."
drivah build --push .
