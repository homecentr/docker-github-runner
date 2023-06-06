FROM node:20-bullseye

ARG RUNNER_VERSION="2.304.0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY start.sh /var/lib/github-runner/start.sh

RUN mkdir /var/lib/github-runner/_template

WORKDIR /var/lib/github-runner/_template

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3-pip=20.3.4-4+deb11u1 \
      dnsutils=1:9.16.37-1~deb11u1 && \
    # Install SOPS
    wget -q -O /usr/bin/sops https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64 && \
    chmod a+x /usr/bin/sops && \
    # Install Ansible & Ansible lint
    python3 -m pip install --no-cache-dir \
      ansible==7.5.0 \
      ansible-lint==6.16.1 \
      # Required to apply playbooks
      netaddr==0.8.0 \
      stormssh==0.7.0 && \
    # Install GitHub runner
    useradd -m github-runner && \
    apt-get install -y --no-install-recommends \
      git=1:2.30.2-1+deb11u2 \
      jq=1.6-2.1 && \
    wget -q -O ./runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./runner.tar.gz && \
    rm runner.tar.gz && \
    chown -R github-runner /var/lib/github-runner && \
    /var/lib/github-runner/_template/bin/installdependencies.sh && \
    chmod a+x /var/lib/github-runner/start.sh && \
    # Install Docker CLI
    apt-get install -y --no-install-recommends \
      ca-certificates=20210119 \
      gnupg=2.2.27-2+deb11u2 && \
    install -m 0755 -d /etc/apt/keyrings && \
    wget -q -O - https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends\
      docker-ce-cli=5:24.0.0-1~debian.11~bullseye && \
    # Clean up apt caches
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,cache,log}/

USER github-runner

ENTRYPOINT [ "/var/lib/github-runner/start.sh" ]