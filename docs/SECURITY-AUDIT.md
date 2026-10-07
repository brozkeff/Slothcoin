# Build5 targeted security audit

2026-10-07; baseline `a4af51f` (build4). Co-authored with Codex 6.1 sol.
This is a targeted maintenance audit, not comprehensive certification or a claim
that all upstream CVEs were backported.

## Fixes

- Signature verification: fix a one-byte buffer over-read.
- Keys: repair private import/copy state, reject absent secrets and invalid curve
  points, sample nonzero scalars/nonces uniformly, and check RNG failures.
- Money: check transaction values and fees before signed addition can overflow.
- Encryption: handle empty buffers, size narrowing, failed plaintext and stale
  keys while preserving the old AES-CBC/KDF format.
- P2P: allocate payloads as received; cap inventory queues and orphan blocks.
- RPC: bound headers, reject ambiguous lengths/transfer encoding/truncated
  bodies; require TLS 1.2 and server certificate/hostname verification.
- Disable legacy signed alerts by default; remove UPnP from supported builds.
- Replace obsolete OpenSSL internals with owned opaque contexts/BIGNUMs and use
  modern Boost APIs and system Crypto++.

## Compatibility

Slothcoin uses custom **P-256 Schnorr**, not Bitcoin's secp256k1/BIP340 scheme.
Modern Crypto++ must use **Keccak**, preserving the original pre-standard SHA3
padding. Fixed vectors check this distinction.

Invalid-point rejection strengthens consensus-facing validation and needs
historical chain replay. Genesis, address prefixes, proof-of-work and reward
rules were not intentionally changed. Duplicate-input rejection was already
present; this is not proof that every inflation path is safe.

[Berkeley DB 4.8](BERKELEY-DB.md) is retained for old wallets. No deliberate DB
format upgrade was introduced; build4 wallet round trips remain untested.

## Evidence and limits

Local daemon/Qt builds and focused normal/ASan/UBSan tests passed with OpenSSL
3.0.2, Crypto++ 8.9 and Boost 1.74. Tests cover key state, malformed signatures,
legacy Keccak vectors, bignum serialization, encryption and amount overflow.
System libraries and bundled SPH hashing are not sanitizer-instrumented.
ELF checks confirm PIE, full RELRO and static Berkeley DB 4.8.30.

The owner confirmed GUI startup, but no peers connected. Clean Ubuntu CI,
historical replay, old-wallet round trips, P2P stress tests and TLS rejection
tests remain pending. Automated wallet/RPC runtime tests are reserved for CI
after a Falcon false positive on this workstation.

Remaining risks include custom-crypto side channels, old Berkeley DB/LevelDB/SPH,
unauthenticated legacy wallet encryption, RPC slow-client handling, mempool
bounds, checkpoint trust and unchecked wallet/mining arithmetic.
See [PLANS.md](../PLANS.md).
