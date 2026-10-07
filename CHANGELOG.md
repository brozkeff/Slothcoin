# Changelog

## [1.3.1-build5] — 2026-10-07 (experimental)

Modernization and security rewrite co-authored with Codex 6.1 sol.

### Added

- Manual Ubuntu 22.04 CI with commit-pinned actions; automatic builds disabled
  until Berkeley DB 4.8 setup is validated on a clean runner.
- Security regression tests, ASan/UBSan checks, and an offline CI wallet/RPC test.
- Build/package scripts, dependency manifest and SHA-256 archive checksums.
- Debian packaging of existing binaries with automatic runtime dependencies,
  desktop integration, checksums, licenses and source snapshots.
- Berkeley DB package provenance and older Ubuntu repository investigation.
- Targeted security audit and modern build instructions in `docs/`.
- TLS client CA configuration via `-rpcsslca`.

### Changed

- Linux builds use OpenSSL 3, Qt 5, modern Boost APIs and system Crypto++.
- Retain Berkeley DB 4.8 for wallet compatibility, building verified source locally
  and linking it statically without replacing system database packages.
- Preserve legacy Keccak signature hashing explicitly when using modern Crypto++.
- Disable UPnP in the supported build and legacy signed network alerts by default.
- Require TLS 1.2 and certificate/hostname verification for RPC HTTPS clients.

### Fixed

- Signature buffer over-read, private-key import/copy state and invalid key state.
- Private-scalar/nonce sampling and invalid private/public-key handling.
- Unchecked OpenSSL RNG failures and wallet encryption edge cases.
- Signed overflow in transaction value and fee accumulation.
- Eager P2P allocation, unbounded inventory queues and orphan block storage.
- Unbounded HTTP headers, ambiguous lengths and truncated RPC bodies.

## [1.3.1-build4] — 2019-12

- Historical Linux build for Ubuntu 16.04, with URL, graphics, seeds and Boost fixes.
