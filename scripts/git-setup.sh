#!/bin/bash
set -ex

export GIT_BRANCH=${BUILDKITE_BRANCH}

git switch -
git checkout $GIT_BRANCH
git pull origin $GIT_BRANCH
git config --local user.email $BUILDKITE_BUILD_CREATOR_EMAIL
git config --local user.name $BUILDKITE_BUILD_CREATOR