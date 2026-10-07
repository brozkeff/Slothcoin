#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
name=slothcoin-v1.3.1-build5-ubuntu22.04-amd64
bdb_prefix="$(realpath -m "${BDB_PREFIX:-$PWD/build-bdb/prefix}")"
mkdir -p "dist/$name"
install -m 755 src/Slothcoind build-qt/Slothcoin-Qt "dist/$name/"
strip --strip-unneeded "dist/$name/Slothcoind" "dist/$name/Slothcoin-Qt"
install -m 644 COPYING docs/BUILD5.md docs/BERKELEY-DB.md \
  docs/SECURITY-AUDIT.md CHANGELOG.md "dist/$name/"
install -m 644 "$bdb_prefix/share/doc/bdb/LICENSE" "dist/$name/COPYING.berkeley-db"
mkdir -p "dist/$name/sources"
install -m 644 build-bdb/db-4.8.30.NC.tar.gz tools/bdb-cxx11.patch \
  tools/build-bdb48.sh "dist/$name/sources/"
bash tools/package-sources.sh "$PWD/dist/$name/sources/slothcoin-build5-source.tar.gz"
{
  git rev-parse HEAD
  git describe --always --dirty
  cat "$bdb_prefix/BUILD-INFO.txt"
  dpkg-query -W g++ libssl-dev libcrypto++-dev libboost-chrono1.74.0 \
    libboost-filesystem1.74.0 libboost-program-options1.74.0 \
    libboost-thread1.74.0 qtbase5-dev
  ldd src/Slothcoind
  ldd build-qt/Slothcoin-Qt
} > "dist/$name/BUILD-INFO.txt"
tar -C dist -czf "dist/$name.tar.gz" "$name"
cd dist
sha256sum "$name.tar.gz" > "$name.tar.gz.sha256"
