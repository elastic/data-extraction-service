#!/bin/bash
set -ex

VERSION=`cat ./VERSION`
GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`

sed -i.bak 's/-SNAPSHOT//g' ./VERSION # Remove the SNAPSHOT suffix
UPDATED_VERSION=`cat ./VERSION`

git add VERSION
git commit -m "Bumping version from ${VERSION} to ${UPDATED_VERSION}"
git push origin ${GIT_BRANCH}

echo "Tagging the release"
git tag "v${UPDATED_VERSION}"
git push origin --tags
