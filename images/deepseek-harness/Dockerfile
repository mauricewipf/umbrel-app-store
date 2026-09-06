FROM node:22-bookworm-slim

# Runtime deps for the harness agent tools (bash, tmux, git, python) + certs.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    openssh-client \
    python3 \
    tmux \
  && rm -rf /var/lib/apt/lists/*

# Published upstream CLI (includes the web UI bundle). Pinned, not latest.
ARG DSH_VERSION=0.1.2-rc.1
RUN npm install -g --no-audit --no-fund "@deepseek-ai/dsh@${DSH_VERSION}" \
  && dsh --version \
  && node --version \
  && mkdir -p /data/.dsh /data/workspace \
  && chown -R 1000:1000 /data

COPY entrypoint.sh /usr/local/bin/dsh-entrypoint.sh
COPY umbrel.patch.yml /app/umbrel.patch.yml
RUN chmod +x /usr/local/bin/dsh-entrypoint.sh

ENV DSH_HOME=/data/.dsh \
    DSH_WORKSPACE=/data/workspace \
    DSH_PORT=3080

WORKDIR /data/workspace
EXPOSE 3080

ENTRYPOINT ["/usr/local/bin/dsh-entrypoint.sh"]
CMD ["web"]
