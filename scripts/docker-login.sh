#!/bin/bash

set -ex

VAULT_ADDR=${VAULT_ADDR:-https://vault-ci-prod.elastic.dev}
VAULT_USER="docker-swiftypeadmin"
echo "Fetching Docker credentials for '$VAULT_USER' from Vault..."
DOCKER_USER=$(vault read -address "${VAULT_ADDR}" -field login secret/ci/elastic-data-extraction-service/${VAULT_USER})
DOCKER_PASSWORD=$(vault read -address "${VAULT_ADDR}" -field password secret/ci/elastic-data-extraction-service/${VAULT_USER})
echo "Done!"
echo

echo "Logging into Docker as '$DOCKER_USER'..."
docker login -u "${DOCKER_USER}" -p ${DOCKER_PASSWORD} docker.elastic.co
echo "Done!"
echo