#!/bin/bash

GH_OWNER=$GH_OWNER
GH_TOKEN=$GH_TOKEN

export CONTAINER_ID=$(cat /proc/self/mountinfo | grep "/docker/containers/" | head -1 | awk '{print $4}' | sed 's/\/var\/lib\/docker\/containers\///g' | sed 's/\/resolv.conf//g' | cut -c1-5)
export FULL_RUNNER_NAME="${RUNNER_NAME}-${CONTAINER_ID}"

# Create a root directory with different name to get a different Docker instance id hash
ROOT_DIR="/var/lib/github-runner/$CONTAINER_ID/" # TODO: Test ?

echo "Creating root directory to $ROOT_DIR..."
mkdir -p $ROOT_DIR

echo "Moving runner root directory to $ROOT_DIR..."
find /var/lib/github-runner/_template -maxdepth 1 -mindepth 1 | xargs -I '{}' mv '{}' "$ROOT_DIR"
cd $ROOT_DIR


echo "Connecting to GitHub org: $GH_OWNER"
echo "Runner name: $FULL_RUNNER_NAME"

REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GH_TOKEN}" https://api.github.com/orgs/${GH_OWNER}/actions/runners/registration-token | jq .token --raw-output)

./config.sh --unattended --url "https://github.com/${GH_OWNER}" --token "${REG_TOKEN}" --name "${FULL_RUNNER_NAME}"

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token "${REG_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!