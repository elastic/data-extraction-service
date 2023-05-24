#!/bin/bash

set -ex
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source "${SCRIPT_DIR}/docker-env.sh"
/bin/bash "${SCRIPT_DIR}/docker-login.sh"

docker push "$BASE_IMAGE_TAG_FINAL"
