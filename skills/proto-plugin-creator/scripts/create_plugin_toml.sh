#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <tool-id> [output-path]" >&2
  exit 1
fi

tool_id="$1"
output_path="${2:-plugins/${tool_id}.toml}"

if [[ ! "$tool_id" =~ ^[a-z0-9-]+$ ]]; then
  echo "Tool ID must be kebab-case: lowercase letters, digits, and hyphens only." >&2
  exit 1
fi

if [[ -e "$output_path" ]]; then
  echo "Refusing to overwrite existing file: $output_path" >&2
  exit 1
fi

mkdir -p "$(dirname "$output_path")"

cat >"$output_path" <<EOF
# A TOML plugin for proto:
# https://moonrepo.dev/docs/proto/non-wasm-plugin

name = "${tool_id}"
type = "cli"

[platform.linux]
bin-path = "${tool_id}"
archive-prefix = "TODO-${tool_id}-{version}-linux-{arch}"
download-file = "TODO-${tool_id}-{version}-linux-{arch}.tar.gz"

[platform.macos]
bin-path = "${tool_id}"
archive-prefix = "TODO-${tool_id}-{version}-darwin-{arch}"
download-file = "TODO-${tool_id}-{version}-darwin-{arch}.tar.gz"

[platform.windows]
bin-path = "${tool_id}.exe"
archive-prefix = "TODO-${tool_id}-{version}-windows-{arch}"
download-file = "TODO-${tool_id}-{version}-windows-{arch}.zip"

[install]
download-url = "https://github.com/ORG/REPO/releases/download/v{version}/{download_file}"
unpack = true

[install.arch]
aarch64 = "arm64"
x86_64 = "amd64"

[resolve]
git-url = "https://github.com/ORG/REPO"
git-tag-pattern = "^(?:v?)(.*)$"
EOF

echo "Created $output_path"
