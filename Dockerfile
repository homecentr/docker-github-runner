FROM node:18-bullseye

ARG RUNNER_VERSION="2.304.0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY start.sh /var/lib/github-runner/start.sh

WORKDIR /var/lib/github-runner

RUN apt-get update && \
    apt-get install -y python3-pip --no-install-recommends && \
    # Install SOPS
    wget -O /usr/bin/sops https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64 && \
    chmod a+x /usr/bin/sops && \
    # Install Ansible & Ansible lint
    python3 -m pip install ansible && \
    python3 -m pip install ansible-lint && \
    # Install GitHub runner
    useradd -m github-runner && \
    apt-get install -y git jq --no-install-recommends && \
    wget -O ./runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./runner.tar.gz && \
    rm runner.tar.gz && \
    chown -R github-runner /var/lib/github-runner && \
    /var/lib/github-runner/bin/installdependencies.sh && \
    chmod a+x /var/lib/github-runner/start.sh && \
    # Install Docker CLI
    apt-get install -y ca-certificates gnupg --no-install-recommends && \
    install -m 0755 -d /etc/apt/keyrings && \
    wget -O - --quiet https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli --no-install-recommends && \
    # Clean up apt caches
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

USER github-runner

ENTRYPOINT [ "/var/lib/github-runner/start.sh" ]