#!/usr/bin/env bash
# Package existing native binaries; never install or start the wallet.
set -euo pipefail
cd "$(dirname "$0")/.."
repo="$PWD"
version="${DEB_VERSION:-1.3.1~build5-1}"
architecture="$(dpkg --print-architecture)"
maintainer="${DEB_MAINTAINER:-Slothcoin contributors <brozkeff@users.noreply.github.com>}"
dpkg --validate-version "$version"
bdb_prefix="$(realpath -m "${BDB_PREFIX:-$repo/build-bdb/prefix}")"
mkdir -p build-deb dist
work="$(mktemp -d "$repo/build-deb/package.XXXXXX")"
root="$work/root"
doc="$root/usr/share/doc/slothcoin"
mkdir -p "$root/DEBIAN" "$root/usr/bin" "$doc/sources" "$work/debian"
install -m 755 src/Slothcoind build-qt/Slothcoin-Qt "$root/usr/bin/"
strip --strip-unneeded "$root/usr/bin/Slothcoind" "$root/usr/bin/Slothcoin-Qt"
ln -s Slothcoind "$root/usr/bin/slothcoind"
ln -s Slothcoin-Qt "$root/usr/bin/slothcoin-qt"
install -m 644 COPYING "$doc/copyright"
install -m 644 "$bdb_prefix/share/doc/bdb/LICENSE" "$doc/COPYING.berkeley-db"
install -m 644 docs/BUILD5.md docs/BERKELEY-DB.md docs/SECURITY-AUDIT.md \
  CHANGELOG.md "$doc/"
install -m 644 build-bdb/db-4.8.30.NC.tar.gz tools/bdb-cxx11.patch \
  tools/build-bdb48.sh "$doc/sources/"
bash tools/package-sources.sh "$doc/sources/slothcoin-build5-source.tar.gz"
install -Dm644 share/qt/slothcoin_128.png \
  "$root/usr/share/icons/hicolor/128x128/apps/slothcoin.png"
install -Dm644 tools/slothcoin.desktop \
  "$root/usr/share/applications/slothcoin.desktop"
printf 'Source: slothcoin\nMaintainer: %s\n\nPackage: slothcoin\nArchitecture: %s\nDescription: Experimental Slothcoin wallet\n' \
  "$maintainer" "$architecture" > "$work/debian/control"
shlibdeps_args=(-O -e"$root/usr/bin/Slothcoind" -e"$root/usr/bin/Slothcoin-Qt")
if [[ -n "${SHLIBDEPS_LIBRARY_DIR:-}" ]]; then
  shlibdeps_args+=(-l"$SHLIBDEPS_LIBRARY_DIR")
fi
if [[ -n "${SHLIBDEPS_SHLIBS_FILE:-}" ]]; then
  shlibdeps_args+=(-L"$SHLIBDEPS_SHLIBS_FILE")
fi
dependencies="$(cd "$work" && dpkg-shlibdeps "${shlibdeps_args[@]}")"
dependencies="${dependencies#shlibs:Depends=}"
[[ -n "$dependencies" && "$dependencies" != *$'\n'* ]]
size="$(du -sk "$root/usr" | cut -f1)"
{
  printf 'Package: slothcoin\nVersion: %s\nArchitecture: %s\n' "$version" "$architecture"
  printf 'Maintainer: %s\nSection: net\nPriority: optional\n' "$maintainer"
  printf 'Installed-Size: %s\nDepends: %s\n' "$size" "$dependencies"
  printf 'Homepage: https://github.com/brozkeff/Slothcoin\n'
  printf 'Description: Experimental Slothcoin daemon and Qt wallet\n'
  printf ' Legacy P-256 Schnorr cryptocurrency wallet, modernized for Ubuntu 22.04.\n'
  printf ' Includes Berkeley DB 4.8 for historical wallet compatibility.\n'
} > "$root/DEBIAN/control"
git rev-parse HEAD > "$doc/BUILD-INFO.txt"
git describe --always --dirty >> "$doc/BUILD-INFO.txt"
cat "$bdb_prefix/BUILD-INFO.txt" >> "$doc/BUILD-INFO.txt"
(cd "$root" && find usr -type f -print0 | sort -z | xargs -0 md5sum) \
  > "$root/DEBIAN/md5sums"
chmod -R go-w "$root"
filename="slothcoin_${version}_${architecture}.deb"
dpkg-deb --root-owner-group --build "$root" "$repo/dist/$filename"
cd "$repo/dist"
sha256sum "$filename" > "$filename.sha256"
