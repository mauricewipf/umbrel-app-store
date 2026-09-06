#!/usr/bin/env bash
# Umbrel entrypoint for DeepSeek Harness (`dsh web`).
# Binds 0.0.0.0 via the bundled --patch overlay (the CLI rejects --host
# 0.0.0.0), persists state under $DSH_HOME, and serves $DSH_WORKSPACE.
set -euo pipefail

DSH_HOME="${DSH_HOME:-/data/.dsh}"
DSH_WORKSPACE="${DSH_WORKSPACE:-/data/workspace}"
DSH_PORT="${DSH_PORT:-3080}"
PATCH_FILE="${DSH_PATCH_FILE:-/app/umbrel.patch.yml}"

mkdir -p "$DSH_HOME" "$DSH_WORKSPACE"
cd "$DSH_WORKSPACE"

export DSH_HOME DSH_PORT

# Non-loopback authorities the /api browser-trust fence must accept.
# Loopback and LAN IP literals are trusted automatically; add Umbrel names
# and any operator-provided extras here.
trusted_args=()
add_trusted() {
  local entry="$1"
  [[ -n "$entry" ]] || return 0
  trusted_args+=(--trusted-host "$entry")
}

# Operator-provided comma-separated list, e.g. "umbrel.local:3080,myhost".
if [[ -n "${DSH_TRUSTED_HOSTS:-}" ]]; then
  IFS=',' read -ra _extra <<< "$DSH_TRUSTED_HOSTS"
  for _e in "${_extra[@]}"; do
    _e="$(echo "$_e" | tr -d '[:space:]')"
    [[ -n "$_e" ]] && add_trusted "$_e"
  done
fi

# Umbrel-provided device/app names when running under umbrelOS.
for _candidate in "${DEVICE_DOMAIN_NAME:-}" "${APP_DOMAIN:-}" "umbrel.local"; do
  [[ -n "$_candidate" ]] && add_trusted "$_candidate"
done

if [[ "${1:-web}" == "web" ]]; then
  # `dsh web` is the `dsh --profile web` alias, but only the root `--profile`
  # form accepts launcher flags like --patch in the published CLI, so the
  # Umbrel overlay (0.0.0.0 bind; the app layer rejects --host 0.0.0.0) is
  # passed as a launcher flag before the profile. Everything after the
  # launcher flags belongs to the web app. Forward any extra args.
  shift || true
  exec dsh \
    --patch "$PATCH_FILE" \
    --profile web \
    --no-open \
    --port "$DSH_PORT" \
    "${trusted_args[@]}" \
    "$@"
fi

# Allow alternate dsh invocations (e.g. `headless`, `--help`).
exec dsh "$@"
