#!/bin/bash

GH_OWNER=$GH_OWNER
GH_TOKEN=$GH_TOKEN
RUNNER_NAME=$RUNNER_NAME

RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)

echo "GH owner: $GH_OWNER"
echo "GH token: $GH_TOKEN"

REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GH_TOKEN}" https://api.github.com/orgs/${GH_OWNER}/actions/runners/registration-token | jq .token --raw-output)

echo "Reg token: $REG_TOKEN"

./config.sh --unattended --url https://github.com/${GH_OWNER} --token ${REG_TOKEN} --name ${RUNNER_NAME}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!