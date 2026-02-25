#!/bin/bash

# !!! WARNING DO NOT add -x to avoid leaking vault passwords
set -euo pipefail

echo "=== Building Docker images ==="
buildah build -f Dockerfile.fips -t extraction-service-fips .
buildah build -t extraction-service .

echo "=== Saving images as artifacts ==="
mkdir -p .artifacts
buildah push extraction-service-fips oci-archive:.artifacts/extraction-service-fips.tar
gzip .artifacts/extraction-service-fips.tar
buildah push extraction-service oci-archive:.artifacts/extraction-service.tar
gzip .artifacts/extraction-service.tar

echo "=== Images built and saved ==="
buildah images
ls -lh .artifacts/extraction-service*.tar.gz
