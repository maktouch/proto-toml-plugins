# Non-WASM Plugin Reference

## Table Of Contents

- [Sources](#sources)
- [Core Structure](#core-structure)
- [Runtime Tokens](#runtime-tokens)
- [Platform/Install Checklist](#platforminstall-checklist)
- [Resolve Options](#resolve-options)
- [Detect Section](#detect-section)
- [Registration And Validation](#registration-and-validation)

## Sources

- Main schema and workflow:
  - `https://moonrepo.dev/docs/proto/non-wasm-plugin`
  - `https://raw.githubusercontent.com/moonrepo/moon/master/website/docs/proto/non-wasm-plugin.mdx`
- Plugin management commands:
  - `https://raw.githubusercontent.com/moonrepo/moon/master/website/docs/proto/commands/plugin/add.mdx`
  - `https://raw.githubusercontent.com/moonrepo/moon/master/website/docs/proto/commands/plugin/list.mdx`
  - `https://raw.githubusercontent.com/moonrepo/moon/master/website/docs/proto/commands/plugin/info.mdx`
  - `https://raw.githubusercontent.com/moonrepo/moon/master/website/docs/proto/commands/plugin/remove.mdx`
- Plugin config in `.prototools`:
  - `https://raw.githubusercontent.com/moonrepo/moon/master/website/docs/proto/config.mdx`
- Locator string protocols:
  - `https://raw.githubusercontent.com/moonrepo/moon/master/website/docs/guides/wasm-plugins.mdx`

## Core Structure

Non-WASM plugins are static JSON/TOML/YAML configs for common tool cases (especially CLIs). They
support download/install/resolve configuration, but not arbitrary runtime logic.

Top-level sections commonly used:

- `name`
- `type` (`language`, `dependency-manager`, `package-manager`, `cli`)
- `[platform.<os>]`
- `[install]`
- `[install.arch]`
- `[resolve]`
- `[detect]` (optional)
- `[packages]` (optional)

## Runtime Tokens

Frequently used token substitutions:

- `{version}`, `{versionMajor}`, `{versionMinor}`, `{versionPatch}`
- `{versionPrerelease}`, `{versionBuild}`
- `{arch}`, `{os}`, `{libc}`
- `{download_file}`, `{checksum_file}`

Use them only in fields that support interpolation, especially in download/checksum URLs and
platform file names.

## Platform/Install Checklist

For each platform entry:

- Define `download-file` (required).
- Define executable location (`bin-path` and/or `exe-path` depending on archive layout).
- Define `archive-prefix` when unpacked archives include a top directory.
- Define `checksum-file` only if checksums are published.

For install section:

- Define `download-url` (required).
- Define `checksum-url` when available.
- Set `unpack = true` for archives.
- Map `[install.arch]` when upstream naming differs from Rust arch names.

Schema note:

- Existing repos may model executables with `bin-path`/`exe-path` in `[platform.*]`.
- Current official docs also include `[install.exes]` for explicit primary/secondary executable
  definitions.
- Prefer the established pattern in the target repo, then validate with `proto install` and
  `proto plugin info`.

## Resolve Options

Choose exactly one primary source of versions:

- Git tags with `git-url`.
- JSON manifest with `manifest-url` (+ `manifest-version-key` when needed).
- Static `versions` and `aliases`.

Use `git-tag-pattern` and/or `version-pattern` when upstream values are prefixed or otherwise not
directly parseable.

## Detect Section

`[detect] version-files = [...]` reads plain files that contain only a version string. Use only when
project conventions guarantee this format.

## Registration And Validation

Configure plugin in `.prototools`:

```toml
[plugins.tools]
my-tool = "file://./plugins/my-tool.toml"
```

Or use command:

```bash
proto plugin add my-tool "file://./plugins/my-tool.toml" --to local --type tool
```

Validate behavior:

```bash
proto plugin list my-tool
proto plugin info my-tool
proto install my-tool
proto list-remote my-tool
```

If needed, remove and re-add:

```bash
proto plugin remove my-tool --from local --type tool
proto plugin add my-tool "file://./plugins/my-tool.toml" --to local --type tool
```
