#!/bin/bash
set -ex

GIT_BRANCH=${BUILDKITE_BRANCH}

git switch -
git checkout $GIT_BRANCH
git pull origin $GIT_BRANCH
git config --local user.email $BUILDKITE_BUILD_CREATOR_EMAIL
git config --local user.name $BUILDKITE_BUILD_CREATOR

VERSION=`cat ./VERSION`

sed -i.bak 's/-SNAPSHOT//g' ./VERSION # Remove the SNAPSHOT suffix
UPDATED_VERSION=`cat ./VERSION`

git add VERSION
git commit -m "Bumping version from ${VERSION} to ${UPDATED_VERSION}"
git push origin ${GIT_BRANCH}

echo "Tagging the release"
git tag "v${UPDATED_VERSION}"
git push origin --tags
