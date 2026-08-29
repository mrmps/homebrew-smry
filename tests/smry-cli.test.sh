#!/bin/sh

set -eu

repository_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' EXIT HUP INT TERM

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  grep -F -x -- "$1" "$2" >/dev/null || fail "expected argument: $1"
}

cat > "$temporary_dir/curl" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > "$SMRY_TEST_OUTPUT"
EOF
chmod +x "$temporary_dir/curl"

version_output=$(PATH="$temporary_dir:$PATH" "$repository_dir/bin/smry" --version)
[ "$version_output" = "smry 0.1.0" ] || fail "unexpected version output"

if PATH="$temporary_dir:$PATH" "$repository_dir/bin/smry" >/dev/null 2>&1; then
  fail "missing URL should fail"
fi

if PATH="$temporary_dir:$PATH" "$repository_dir/bin/smry" file:///tmp/private >/dev/null 2>&1; then
  fail "non-HTTP URL should fail"
fi

if PATH="$temporary_dir:$PATH" "$repository_dir/bin/smry" https://example.com/a https://example.com/b >/dev/null 2>&1; then
  fail "multiple URLs should fail"
fi

arguments_file="$temporary_dir/arguments"
SMRY_TEST_OUTPUT="$arguments_file" PATH="$temporary_dir:$PATH" \
  "$repository_dir/bin/smry" \
  --json \
  --query "key findings" \
  --lines 90-95 \
  --passages 4 \
  "https://example.com/report.pdf?download=1"

assert_contains "https://r.smry.ai/api/v1/read" "$arguments_file"
assert_contains "url=https://example.com/report.pdf?download=1" "$arguments_file"
assert_contains "Accept: application/json" "$arguments_file"
assert_contains "User-Agent: smry-cli/0.1.0" "$arguments_file"
assert_contains "X-Smry-Query: key findings" "$arguments_file"
assert_contains "X-Smry-Lines: 90-95" "$arguments_file"
assert_contains "X-Smry-Passages: 4" "$arguments_file"

printf 'smry CLI tests passed\n'
