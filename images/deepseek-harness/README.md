# deepseek-harness Umbrel image

Wrapper image that runs [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness)
(`dsh web`) on umbrelOS. Upstream ships no Docker image, so this installs the
published npm CLI (`@deepseek-ai/dsh`, pinned via `DSH_VERSION`) on
`node:22-bookworm-slim` and adds the Umbrel glue:

- `entrypoint.sh` — persists state under `$DSH_HOME`, serves `$DSH_WORKSPACE`,
  passes Umbrel hostnames as `--trusted-host` so the `/api` browser-trust
  fence accepts `app_proxy` traffic.
- `umbrel.patch.yml` — `--patch` overlay binding the webserver to `0.0.0.0`
  (the CLI layer rejects `--host 0.0.0.0`; the webserver schema allows it).

## Publish a new version

Push a tag `deepseek-harness-v<DSH_VERSION>` (e.g. `deepseek-harness-v0.1.2-rc.1`);
the workflow builds `linux/amd64` + `linux/arm64` and pushes
`ghcr.io/mauricewipf/deepseek-harness-umbrel:<DSH_VERSION>`.
Or run the workflow manually with a version input.

After pushing, pin the new digest in the Umbrel app's `docker-compose.yml`:

```sh
docker buildx imagetools inspect ghcr.io/mauricewipf/deepseek-harness-umbrel:<DSH_VERSION> --format '{{json .Manifest}}' | head -c 300
```

then use `image: ghcr.io/mauricewipf/deepseek-harness-umbrel:<DSH_VERSION>@sha256:<digest>`.

## Test locally

```sh
docker build -t deepseek-harness-umbrel:local images/deepseek-harness
mkdir -p /tmp/dsh-home /tmp/dsh-ws
docker run --rm -p 38080:3080 \
  -v /tmp/dsh-home:/data/.dsh -v /tmp/dsh-ws:/data/workspace \
  deepseek-harness-umbrel:local
# copy the ?token= URL from the logs, open it, session cookie lasts 30 days
```
