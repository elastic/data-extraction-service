#!/bin/bash
set -ex

source scripts/git-setup.sh

VERSION=`cat ./VERSION`
VERSION_MAJOR="${VERSION%%\.*}"
VERSION_MINOR="${VERSION#*.}"
VERSION_MINOR="${VERSION_MINOR%.*}"
VERSION_PATCH="${VERSION##*.}"

if [[ "$VERSION" == *.0 ]]; then
  NEW_BRANCH=$(echo "$VERSION" | sed "s/.0\$//")
  echo "Creating new branch: ${NEW_BRANCH}"
  git checkout -b ${NEW_BRANCH}

  BUMPED_PATCH=$(($VERSION_PATCH+1))
  NEW_VERSION="${VERSION_MAJOR}.${VERSION_MINOR}.${BUMPED_PATCH}-SNAPSHOT"
  echo "${NEW_VERSION}" > ./VERSION
  git add VERSION
  git commit -m "Bumping version from ${VERSION} to ${NEW_VERSION} on branch: ${NEW_BRANCH}"
  git push origin ${NEW_BRANCH}

  git checkout ${GIT_BRANCH} # going back to the previous branch
  BUMPED_MINOR=$(($VERSION_MINOR+1))
  NEW_VERSION="${VERSION_MAJOR}.${BUMPED_MINOR}.0-SNAPSHOT"
  echo "${NEW_VERSION}" > ./VERSION
  git add VERSION
  git commit -m "Bumping version from ${VERSION} to ${NEW_VERSION} on branch: ${GIT_BRANCH}"
  git push origin ${GIT_BRANCH}
else
  echo "Since version ${VERSION} is not a 'dot oh' version, no new branch is needed"

  BUMPED_PATCH=$(($VERSION_PATCH+1))
  NEW_VERSION="${VERSION_MAJOR}.${VERSION_MINOR}.${BUMPED_PATCH}-SNAPSHOT"
  echo "${NEW_VERSION}" > ./VERSION
  git add VERSION
  git commit -m "Bumping version from ${VERSION} to ${NEW_VERSION} on branch: ${GIT_BRANCH}"
  git push origin ${GIT_BRANCH}
fi


