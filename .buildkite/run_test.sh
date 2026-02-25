#!/bin/bash

# !!! WARNING DO NOT add -x to avoid leaking vault passwords
set -euo pipefail

echo "=== Loading pre-built Docker image ==="
mkdir -p .artifacts
buildkite-agent artifact download '.artifacts/extraction-service.tar.gz' .artifacts/ --step build_images
docker load <.artifacts/extraction-service.tar.gz
rm -f .artifacts/extraction-service.tar.gz

make e2e
