#!/bin/bash

# !!! WARNING DO NOT add -x to avoid leaking vault passwords
set -euo pipefail

echo "=== Loading pre-built Docker image ==="
mkdir -p .artifacts
buildkite-agent artifact download '.artifacts/extraction-service.tar.gz' .artifacts/ --step build_images
gunzip .artifacts/extraction-service.tar.gz
buildah pull oci-archive:.artifacts/extraction-service.tar
rm -f .artifacts/extraction-service.tar

echo "=== Starting extraction-service ==="
drivah run .
