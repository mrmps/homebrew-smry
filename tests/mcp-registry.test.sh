#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

mcp-publisher validate server.json

test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
curl --fail --silent --show-error https://r.smry.ai/mcp \
  --request POST \
  --header 'Accept: application/json, text/event-stream' \
  --header 'Content-Type: application/json' \
  --dump-header "$test_dir/headers" \
  --output "$test_dir/body" \
  --data '{"jsonrpc":"2.0","id":"registry-smoke","method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"registry-smoke","version":"1.0.0"}}}'

content_type="$(awk 'BEGIN { IGNORECASE=1 } /^content-type:/ { gsub("\r", ""); print $2; exit }' "$test_dir/headers")"
if [[ "$content_type" == application/json* ]]; then
  response="$(<"$test_dir/body")"
elif [[ "$content_type" == text/event-stream* ]]; then
  response="$(sed -n 's/^data: //p' "$test_dir/body" | head -n 1)"
else
  echo "Unexpected MCP content type: $content_type" >&2
  exit 1
fi

jq --exit-status '
  .jsonrpc == "2.0"
  and .id == "registry-smoke"
  and (.result.protocolVersion | type == "string")
  and .result.serverInfo.name == "smry-public-reader"
' <<<"$response" >/dev/null

echo "MCP registry metadata and remote initialize checks passed."
