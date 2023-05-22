#!/bin/bash

GH_OWNER=$GH_OWNER
GH_TOKEN=$GH_TOKEN

CONTAINER_ID=$(head -1 /proc/self/cgroup | cut -d/ -f3 | cut -c1-5)
RUNNER_NAME="$RUNNER_NAME-$CONTAINER_ID"

echo "Connecting to GitHub org: $GH_OWNER"
echo "Runner name: $RUNNER_NAME"

REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GH_TOKEN}" https://api.github.com/orgs/${GH_OWNER}/actions/runners/registration-token | jq .token --raw-output)

./config.sh --unattended --url https://github.com/${GH_OWNER} --token ${REG_TOKEN} --name ${RUNNER_NAME}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!