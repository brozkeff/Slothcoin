#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
jobs="${BUILD_JOBS:-2}"
boost_args=()
if [[ -n "${BOOST_INCLUDE_PATH:-}" ]]; then
  boost_args+=("BOOST_INCLUDE_PATH=$BOOST_INCLUDE_PATH")
fi
if [[ -n "${BOOST_LIB_PATH:-}" ]]; then
  boost_args+=("BOOST_LIB_PATH=$BOOST_LIB_PATH")
fi
bdb_prefix="$(realpath -m "${BDB_PREFIX:-$PWD/build-bdb/prefix}")"
BDB_PREFIX="$bdb_prefix" bash tools/build-bdb48.sh
make -C src -f makefile.unix -j"$jobs" USE_UPNP=- PIE=1 \
  BDB_INCLUDE_PATH="$bdb_prefix/include" BDB_LIB_PATH="$bdb_prefix/lib" \
  "${boost_args[@]}"
mkdir -p build-qt
cd build-qt
qmake ../slothcoin-qt.pro USE_UPNP=- RELEASE=1 \
  BDB_INCLUDE_PATH="$bdb_prefix/include" BDB_LIB_PATH="$bdb_prefix/lib" \
  "${boost_args[@]}"
make -j"$jobs"
