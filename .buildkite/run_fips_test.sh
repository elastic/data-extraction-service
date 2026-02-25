#!/bin/bash

# !!! WARNING DO NOT add -x to avoid leaking vault passwords
set -euo pipefail

echo "=== Loading pre-built FIPS Docker image ==="
mkdir -p .artifacts
buildkite-agent artifact download '.artifacts/extraction-service-fips.tar.gz' .artifacts/ --step build_images
docker load <.artifacts/extraction-service-fips.tar.gz
rm -f .artifacts/extraction-service-fips.tar.gz

make fips-e2e
