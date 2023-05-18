[![Project status](https://badgen.net/badge/project%20status/stable%20%26%20actively%20maintaned?color=green)](https://github.com/homecentr/docker-github-runner/graphs/commit-activity) [![](https://badgen.net/github/label-issues/homecentr/docker-github-runner/bug?label=open%20bugs&color=green)](https://github.com/homecentr/docker-github-runner/labels/bug) [![](https://badgen.net/github/release/homecentr/docker-github-runner)](https://hub.docker.com/repository/docker/homecentr/github-runner)
[![](https://badgen.net/docker/pulls/homecentr/github-runner)](https://hub.docker.com/repository/docker/homecentr/github-runner) 
[![](https://badgen.net/docker/size/homecentr/github-runner)](https://hub.docker.com/repository/docker/homecentr/github-runner)

![CI/CD on master](https://github.com/homecentr/docker-github-runner/workflows/CI/CD%20on%20master/badge.svg)


# Homecentr - github-runner

## Usage

```yml
version: "3.7"
services:
  github-runner:
    build: .
    image: homecentr/github-runner
```

## Environment variables

| Name | Default value | Description |
|------|---------------|-------------|
| PUID | 7077 | UID of the user github-runner should be running as. |
| PGID | 7077 | GID of the user github-runner should be running as. |

## Exposed ports

| Port | Protocol | Description |
|------|------|-------------|
| 80 | TCP | Some useful details |

## Volumes

| Container path | Description |
|------------|---------------|
| /config | Some useful details |

## Security
The container is regularly scanned for vulnerabilities and updated. Further info can be found in the [Security tab](https://github.com/homecentr/docker-github-runner/security).

### Container user
The container supports privilege drop. Even though the container starts as root, it will use the permissions only to perform the initial set up. The github-runner process runs as UID/GID provided in the PUID and PGID environment variables.

:warning: Do not change the container user directly using the `user` Docker compose property or using the `--user` argument. This would break the privilege drop logic.