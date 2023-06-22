#!/bin/bash
set -ex

export GIT_BRANCH=${BUILDKITE_BRANCH}

git switch -
git checkout $GIT_BRANCH
git pull origin $GIT_BRANCH
git config --local user.email 'Elastic Machine'
git config --local user.name 'elasticmachine@users.noreply.github.com'