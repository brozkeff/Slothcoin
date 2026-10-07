# Berkeley DB 4.8 compatibility

Build5 retains the ancient 4.8 database library used by the Ubuntu 16.04-era
wallet to avoid upgrading old `wallet.dat` files to a newer Berkeley DB format.
Any future incompatible upgrade needs a new major version. Compatibility still
requires testing with backed-up copies of historical wallets.

This workstation has `libdb4.8`, `libdb4.8++` and their development packages at
**4.8.30-xenial4**, retained from its earlier Ubuntu installation. APT has no
current source for them. A [matching Bitcoin-family PPA publication](https://api.launchpad.net/1.0/~bitcoin-abc/+archive/ubuntu/ppa/+sourcepub/7957414)
is marked deleted; the original installation source is unknown.

Official Ubuntu 18.04/20.04 main and universe indexes contain no `libdb4.8`.
Adding those archives with priority pins therefore does not supply it. Installing
Jammy's `libdb5.3-dev` can remove the old development headers.

`tools/build-bdb48.sh` instead builds verified Oracle 4.8.30.NC source into the
workspace and links it statically. A pinned [Bitcoin Core compiler patch](https://github.com/bitcoin/bitcoin/blob/af591f2068d0363c92d9756ca39c43db85e5804c/depends/patches/bdb/clang_cxx_11.patch)
renames atomic identifiers without changing storage. Both binaries contain 4.8.30
and have no shared Berkeley DB dependency; newer headers are rejected.

Source SHA-256:
`12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef`

Patch SHA-256:
`e9c3b2f953057635454dba20f5a8ab47be68b74471ba40c1d2c53022ce373529`

Local compilation succeeded. Clean Ubuntu 22.04 CI remains unvalidated, so
automatic builds are disabled. The source, patch and license ship in packages;
the old DB library remains security debt.
