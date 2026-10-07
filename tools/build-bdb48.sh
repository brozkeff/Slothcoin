#!/usr/bin/env bash
# Build the legacy wallet dependency without changing system packages.
set -euo pipefail
cd "$(dirname "$0")/.."
repo="$PWD"
prefix="$(realpath -m "${BDB_PREFIX:-$repo/build-bdb/prefix}")"
work="$repo/build-bdb"
version=db-4.8.30.NC
archive="$work/$version.tar.gz"
expected=12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef
mkdir -p "$work"
if [[ ! -f "$archive" ]]; then
  curl --fail --location --silent --show-error --proto '=https' --tlsv1.2 \
    --output "$archive" "https://download.oracle.com/berkeley-db/$version.tar.gz"
fi
printf '%s  %s\n' "$expected" "$archive" | sha256sum --check
tar -xzf "$archive" -C "$work"
patch -d "$work/$version" -p1 < "$repo/tools/bdb-cxx11.patch"
cd "$work/$version/build_unix"
CFLAGS='-O2 -fPIC -fstack-protector-strong' \
  CXXFLAGS='-O2 -fPIC -fstack-protector-strong -std=c++11' \
  ../dist/configure --prefix="$prefix" --enable-cxx --disable-shared \
    --disable-replication --with-pic
make -j"${BUILD_JOBS:-2}" libdb_cxx-4.8.a libdb-4.8.a
make install_lib install_include
mkdir -p "$prefix/share/doc/bdb"
install -m 644 "$work/$version/LICENSE" "$prefix/share/doc/bdb/LICENSE"
printf 'Berkeley DB 4.8.30.NC\nsource-sha256=%s\n' "$expected" > "$prefix/BUILD-INFO.txt"
sha256sum "$repo/tools/bdb-cxx11.patch" >> "$prefix/BUILD-INFO.txt"
