# Build5: Linux build and packages

Experimental Ubuntu 22.04 maintenance release, co-authored with Codex 6.1 sol.
The local build uses OpenSSL 3, Qt 5.15, Boost 1.74, Crypto++ 8.9 and static
Berkeley DB 4.8.30.NC. This upgraded workstation is not a clean Jammy baseline.
Windows, macOS/OS X and other legacy build scripts need porting.

## Build

Required development packages: `build-essential`, `curl`, `patch`, `libssl-dev`,
`libcrypto++-dev`, Boost system/filesystem/thread/program-options/chrono headers,
`qtbase5-dev`, `qttools5-dev-tools`, and `libqrencode-dev`.

```sh
bash tools/build-ubuntu22.sh
make -C src -f makefile.unix BDB_INCLUDE_PATH="$PWD/build-bdb/prefix/include" check-security
make -C src -f makefile.unix BDB_INCLUDE_PATH="$PWD/build-bdb/prefix/include" check-security-sanitized
```

`BUILD_JOBS` sets parallelism (default 2). `BOOST_INCLUDE_PATH` and
`BOOST_LIB_PATH` support extracted development packages. The outputs are
`src/Slothcoind` and `build-qt/Slothcoin-Qt`. UPnP is excluded; both binaries use
PIE, stack protection and full RELRO.

The helper builds Berkeley DB into `build-bdb/prefix`; no system DB package is
replaced. Stock Jammy lacks 4.8, so automatic Actions triggers are commented out
until this setup is validated on a clean runner. Manual dispatch remains for
testing the proposed source-build solution. Enabling a build without supplying
4.8 headers/libraries will fail. Actions remain pinned to exact commits.

## Package and run

```sh
bash tools/package-build5.sh
bash tools/package-deb.sh
```

Outputs under `dist/` are a tar archive, `.deb` and SHA-256 checksums. Both include
binaries, documentation, licenses and source snapshots. The `.deb` adds desktop
integration and calculates dependencies with `dpkg-shlibdeps`; it installs no
service and does not start the wallet. `DEB_VERSION` and `DEB_MAINTAINER` override
its metadata. Extracted libraries can supply `SHLIBDEPS_LIBRARY_DIR` and
`SHLIBDEPS_SHLIBS_FILE` from their package metadata.

The tar archive requires installed OpenSSL 3, Qt 5, Crypto++, QRencode and Boost
1.74 runtime libraries, including **`libboost-chrono1.74.0`**. Local packages
require **Crypto++ 8.9**, which is newer than stock Jammy's 8.6. They were built
on an upgraded Mint/Ubuntu 22.04 host; they are not clean-Jammy or universal Linux
binaries. Inspect the package dependencies before installation.

Try a disposable data directory first. Keep a backup of any old `wallet.dat`.
No public peers connected in the local check; normal network operation is
unverified. Git push, tagging and release upload are manual steps.

## Behavior and validation

RPC HTTPS requires TLS 1.2 and certificate/hostname verification. Private CAs
use `-rpcsslca=/path/to/ca.pem`. Legacy signed alerts are disabled; `-alerts=1`
opts back in. RPC defaults to loopback; slow-client timeouts remain outstanding.

Local daemon/Qt compilation, focused regressions and ASan/UBSan passed. The owner
confirmed the GUI starts after installing its missing Boost Chrono runtime.
`tools/smoke-test.py` uses disposable offline wallets; it is reserved for CI on
this Falcon-protected workstation. Clean CI, historical replay and old-wallet
round trips remain pending. See [the audit](SECURITY-AUDIT.md).
