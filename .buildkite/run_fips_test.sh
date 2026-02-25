#!/bin/bash

# !!! WARNING DO NOT add -x to avoid leaking vault passwords
set -euo pipefail

echo "=== Loading pre-built FIPS Docker image ==="
mkdir -p .artifacts
buildkite-agent artifact download '.artifacts/extraction-service-fips.tar.gz' .artifacts/ --step build_images
gunzip .artifacts/extraction-service-fips.tar.gz
buildah pull oci-archive:.artifacts/extraction-service-fips.tar
rm -f .artifacts/extraction-service-fips.tar

echo "=== Starting extraction-service (FIPS) ==="
drivah run .
