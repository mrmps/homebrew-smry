#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

mcp-publisher validate server.json

response="$({
  curl --fail --silent --show-error https://r.smry.ai/mcp \
    --request POST \
    --header 'Accept: application/json, text/event-stream' \
    --header 'Content-Type: application/json' \
    --data '{"jsonrpc":"2.0","id":"registry-smoke","method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"registry-smoke","version":"1.0.0"}}}'
})"

jq --exit-status '
  .jsonrpc == "2.0"
  and .id == "registry-smoke"
  and (.result.protocolVersion | type == "string")
  and .result.serverInfo.name == "smry-public-reader"
' <<<"$response" >/dev/null

echo "MCP registry metadata and remote initialize checks passed."
