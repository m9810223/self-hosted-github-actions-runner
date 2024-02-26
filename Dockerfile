# syntax = docker.io/docker/dockerfile:latest

FROM ubuntu:22.04
ARG RUNNER_PACKAGE_URL=https://github.com/actions/runner/releases/download/v2.313.0/actions-runner-linux-arm64-2.313.0.tar.gz
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /actions-runner

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    : \
    && apt update \
    && apt-get --no-install-recommends install -y curl ca-certificates
RUN curl -o _.tar.gz -L $RUNNER_PACKAGE_URL
RUN tar xzf _.tar.gz && rm -rf _.tar.gz

RUN useradd runner_user && chown -R runner_user /actions-runner
RUN bin/installdependencies.sh

RUN cat <<EOF >/actions-runner/entrypoint.sh && chmod +x entrypoint.sh
#!/bin/bash
./config.sh --url https://github.com/\$GH_OWNER --token \$GH_TOKEN
./run.sh
EOF
USER runner_user
ENTRYPOINT ["/actions-runner/entrypoint.sh"]
