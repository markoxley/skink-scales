# scales — Skink Package Manager & Module Resolution System

`scales` is the official package manager and third-party module resolution system for the **Skink** programming language. Written in Skink, it provides decentralized GitHub-backed dependency management with an APT/DNF-style local package and index cache.

---

## 1. Source Import Syntax

Third-party modules are imported directly in Skink source files using the `mod/<github_owner>/<repo_name>[@version]` syntax:

```skink
module main

// Explicit version specifier:
import "mod/markoxley/skink-tegu@v1.0.2"

// Omitted version specifier (resolves via skink.lock / skink.toml or latest version):
import "mod/markoxley/skink-tegu"

// Optional import alias:
import "mod/markoxley/skink-tegu@v1.0.2" as orm
```

---

## 2. Project Manifest (`skink.toml`) & Lockfile (`skink.lock`)

`scales` manages a project manifest named `skink.toml` (with automatic fallback support for `skink.mod`) and a deterministic lockfile `skink.lock`.

```toml
# Skink Project Manifest (managed by scales)

[package]
name = "my-app"
version = "0.1.0"
author = "mark"
entry = "main.skink"
license = "Apache-2.0"

[target]
env = "std"          # "std", "no-std", or "bare-metal"
no_std = false       # true for freestanding / bare-metal environments
os = "any"           # "any", "linux", "windows", "darwin", "none"
arch = "any"         # "any", "x86_64", "arm64", "riscv64"

[dependencies]
"mod/markoxley/skink-tegu" = "v1.0.2"
"mod/markoxley/skink-hal" = { version = "^0.2.0", target = "no-std" }
```

### Supported Version Constraints
- Exact tag: `"v1.0.2"` or `"=1.0.2"`
- Caret (SemVer-compatible upgrades): `"^1.0.2"`
- Tilde (patch-level upgrades): `"~1.0.2"`
- Comparison ranges: `">=1.0.0, <2.0.0"`
- Wildcard / Latest: `"*"` or `"latest"`

---

## 3. Local Cache & Metadata Index (`~/.local/skink/scales`)

Similar to `apt` or `dnf`, `scales` maintains a host-local cache so packages are fetched once and reused across projects and offline builds:

- `<cache_root>/index/index.json` & `<cache_root>/index/<owner>/<repo>/tags.json` — Lightweight local metadata index cache of available GitHub tags/versions.
- `<cache_root>/archives/<owner>__<repo>__<version>.tar.gz` — Downloaded release archives.
- `<cache_root>/packages/<owner>/<repo>/<version>/` — Unpacked module trees with `.scales_meta.json` (SHA-256 integrity hash and provenance), resolved directly by the `skink` compiler and `skink-lsp`.

Cache location precedence (cross-platform Linux, macOS, and Windows):
1. `$SCALES_CACHE_DIR`
2. `$SKINK_PREFIX/scales`
3. `$HOME/.local/skink/scales` (or `%USERPROFILE%\.local\skink\scales` on Windows)

---

## 4. CLI Commands

```bash
# Initialize a new skink.toml manifest in the current directory
scales init [name] [--no-std | --bare-metal]

# Add a dependency to skink.toml and fetch/cache it from GitHub
scales add mod/<owner>/<repo>[@version] [--target <std|no-std>] [--offline]

# Resolve and fetch all dependencies defined in skink.toml into the local cache
scales install [--offline]
scales restore [--offline]

# Refresh the local metadata index and update dependencies within version constraints
scales update [mod/<owner>/<repo>]

# Remove a dependency from skink.toml and skink.lock
scales remove mod/<owner>/<repo>

# List project dependencies and their resolved/cached status
scales list

# Print the resolved local .skink file path for a module import
scales resolve mod/<owner>/<repo>[@version]

# Inspect or clean the local cache
scales cache list
scales cache path
scales cache clean
```

---

## 5. Building, Testing, and Installing

```bash
make          # Compile the scales binary using skink
make check    # Type-check only
make test     # Run the unit and integration test suite
make install  # Install scales to ~/.local/skink/bin/scales
```
