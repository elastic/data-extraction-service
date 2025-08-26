# Releasing (Elastic employees only)

To release a new version of Elastic Extraction Service, you need to run a special buildkite job. Follow the process below:

1. Create a dev branch off of the branch you want to release from.
  Branch off of `main` to release a new minor version, or branch off of the relevant maintenance branch (`x.y`) to release a new patch version.
  Push your new branch to the origin remote.
2. Go to the [buildkite release pipeline](https://buildkite.com/elastic/data-extraction-service-release)
2. Click `New Build`,
2. Select `HEAD` for `Commit`.
3. For `Branch`, select your new dev branch
4. click `Create Build`.
5. After the build succeeds, it will have created a few commits in your dev branch, and a git tag for the new version.
6. Create a PR from your dev branch back into the branch you'd built it off of.
7. Once that PR is merged, you're done

This will release a new version, create a new maintenance branch (if applicable), build a docker image, and push it to https://docker.elastic.co, and bump the version file(s) to the next version(s).

You can confirm new image is released with:
- Running `docker pull docker.elastic.co/integrations/data-extraction-service:{x.y.z}`
- Checking available versions in https://www.docker.elastic.co/r/integrations/data-extraction-service
