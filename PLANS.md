# Build5 follow-up

- [ ] Run the clean Ubuntu 22.04 workflow and inspect uploaded artifacts.
- [ ] Install the CI-built `.deb` on a disposable clean Jammy system.
- [ ] Replay an archived Slothcoin chain and compare results with build4.
- [ ] Resolve invalid-point validation compatibility before a stable release.
- [ ] Test build4/build5 wallet round trips with Berkeley DB 4.8 using disposable
  copies.
- [ ] Audit retained Berkeley DB 4.8; require a major version for incompatible upgrades.
- [ ] Add fixed historical signature and encrypted-wallet fixtures.
- [ ] Review custom P-256 Schnorr implementation for side channels and nonce safety.
- [ ] Add P2P header/queue/orphan stress tests and fuzz serialization.
- [ ] Add TLS certificate/hostname rejection tests and RPC slow-client timeouts.
- [ ] Replace or audit bundled LevelDB; audit retained SPH hashing.
- [ ] Assess mempool bounds, reward/difficulty edge cases and checkpoint authority.
- [ ] Audit remaining wallet totals and mining-priority arithmetic for overflow.
- [ ] Check seeds/peers separately; document a manual peer configuration if needed.
- [ ] Test native rebuilds on newer Ubuntu releases and document runtime packaging.
- [ ] Decide whether to maintain Windows/macOS builds or mark their projects archival.
- [ ] Mark build5 stable and publish only after the release gates are met.
