set -ex

echo "We made it to the script!"

echo "our working dir is: $(pwd)"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
version_file="${SCRIPT_DIR}/../../VERSION"
version=$(head $version_file)
echo "And the version is: ${version}"