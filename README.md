# Slothcoin (SLOTH)

An experimental 2026 revival of this ancient cryptocurrency wallet, for fun and
preservation. Build5 updates the Linux daemon and Qt wallet for Ubuntu 22.04,
OpenSSL 3, Qt 5, Boost 1.74 and system Crypto++.

**As of 2026, probably no live public nodes remain.** The wallet runs locally,
but no peers connected during the local check. Synchronization and transactions
require reachable peers; this release does not revive the network.

The ancient **Berkeley DB 4.8** used by the Ubuntu 16.04-era wallet is retained
to keep compatibility with old `wallet.dat` files. Build5 links a verified source
build of 4.8 statically. Back up historical wallets before opening a copy;
build4/build5 wallet round trips and historical chain replay remain untested.

Only the Linux build has been updated. Old macOS/OS X, Windows and other platform
build scripts will not work as-is and need porting. Automatic GitHub Actions
builds are disabled until the Berkeley DB 4.8 setup is validated on a clean
Ubuntu 22.04 runner.

- [Build and package instructions](docs/BUILD5.md)
- [Security audit](docs/SECURITY-AUDIT.md)
- [Database compatibility](docs/BERKELEY-DB.md)
- [Changelog](CHANGELOG.md) and [remaining work](PLANS.md)
- [Linux releases](https://github.com/brozkeff/Slothcoin/releases)

Build5 modernization and security rewrite co-authored with **Codex 6.1 sol**.

## History and protocol

Build4 was compiled for Ubuntu 16.04 in December 2019. Build5 is experimental;
it includes targeted security fixes rather than a complete audit.

Slothcoin uses Keccak proof-of-work, custom P-256 Schnorr signatures, a nominal
150-second block interval, and a height-based reward schedule ending at block
1,230,387. Legacy Keccak signature hashing is preserved.

Slothcoin source is licensed under MIT; see [COPYING](COPYING). Packaged Berkeley
DB has its own included license.
