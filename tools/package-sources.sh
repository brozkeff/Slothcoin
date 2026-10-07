#!/usr/bin/env bash
# Capture tracked and new source files, including uncommitted build5 changes.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p dist
output="${1:-$PWD/dist/slothcoin-build5-source.tar.gz}"
{
  git ls-files --cached -z
  git ls-files --others --exclude-standard -z -- \
    .github docs tools src/test CHANGELOG.md PLANS.md
} |
  tar --null --verbatim-files-from --no-recursion \
    --exclude='src/obj/*' -T - -czf "$output"
