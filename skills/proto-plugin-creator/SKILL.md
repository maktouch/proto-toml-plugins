---
name: proto-plugin-creator
description: Create and update proto non-WASM plugin definitions (TOML/JSON/YAML) for CLIs and other tools, including platform download mapping, install settings, version resolution, and plugin registration in .prototools. Use when asked to create a new proto plugin file, migrate an existing plugin, troubleshoot plugin install/resolve behavior, or wire a local/remote plugin locator.
---

# Proto Plugin Creator

## Overview

Build reliable proto non-WASM plugins by following a deterministic workflow: collect release facts,
generate a starter plugin, fill platform/install/resolve blocks, and validate by exercising proto
plugin commands.

For field-level details and current schema behavior, read [`references/non-wasm-plugin.md`](references/non-wasm-plugin.md).

## Workflow

1. Gather required inputs
2. Generate a starter plugin TOML
3. Fill platform and install sections
4. Fill resolve and optional detect sections
5. Register plugin and validate behavior
6. Iterate until install + resolve commands pass

## 1) Gather Required Inputs

Collect these facts before writing fields:

- Plugin ID and display name (usually same lowercase ID).
- Tool type: `cli`, `language`, `dependency-manager`, or `package-manager`.
- Upstream release source:
  - Git tags URL or JSON manifest URL for versions.
  - Download URL pattern and per-platform asset names.
- Archive layout:
  - Whether archives unpack into a prefix directory.
  - Primary executable path for each platform.
- Architecture naming differences (`aarch64` vs `arm64`, `x86_64` vs `amd64`).
- Optional version detection files (for `[detect]`).

## 2) Generate A Starter Plugin

Use the bundled script for a consistent baseline:

```bash
./skills/proto-plugin-creator/scripts/create_plugin_toml.sh <tool-id> [output-path]
```

Example:

```bash
./skills/proto-plugin-creator/scripts/create_plugin_toml.sh doctl plugins/doctl.toml
```

Then replace all `TODO` markers with concrete values.

## 3) Fill Platform And Install

For each OS under `[platform.<os>]`, define:

- `download-file` (required)
- `bin-path` or `exe-path` (matching your archive layout)
- `archive-prefix` when archives unpack into a parent folder
- `checksum-file` when checksums are published

Prefer the executable style already used by the target repository. Existing repos may use platform
`bin-path`/`exe-path`, while newer docs also show `[install.exes]` for explicit primary and
secondary executables.

In `[install]`, define:

- `download-url` (required)
- `checksum-url` when checksum verification is supported
- `unpack = true` when downloading archives
- `[install.arch]` mappings when upstream architecture labels differ

Use runtime tokens like `{version}`, `{arch}`, `{os}`, `{libc}`, `{download_file}`, and
`{checksum_file}` only where they are valid.

## 4) Fill Resolve And Detect

Use one resolve strategy:

- Git tags: `[resolve] git-url = "..."`
- JSON manifest: `[resolve] manifest-url = "..."`
- Static versions/aliases: `[resolve.versions]` and `[resolve.aliases]`

Add `git-tag-pattern` or `version-pattern` when upstream tags/values are not clean semantic
versions.

For local version detection, add `[detect] version-files = [...]` only when real version files
exist and contain only the raw version string.

## 5) Register And Validate

Register plugin in `.prototools` (or use command):

```toml
[plugins.tools]
my-tool = "file://./plugins/my-tool.toml"
```

Or:

```bash
proto plugin add my-tool "file://./plugins/my-tool.toml" --to local --type tool
```

Validate with:

```bash
proto plugin list my-tool
proto plugin info my-tool
proto install my-tool
proto list-remote my-tool
```

If install fails:

- Re-check `download-file`, `archive-prefix`, and executable paths.
- Re-check `[install.arch]` mapping for host architecture.
- Re-check URL/token interpolation.

If version resolution fails:

- Re-check `git-url` or `manifest-url`.
- Add/fix `git-tag-pattern` or `version-pattern`.

## 6) Keep Edits Minimal And Verifiable

- Prefer small changes in one section at a time.
- Re-run `proto plugin info` and `proto install` after every significant change.
- Keep plugin IDs kebab-case and stable over time.
