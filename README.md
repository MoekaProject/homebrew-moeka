# Homebrew Cask

`Casks/moeka.rb` tracks the signed, notarized architecture-specific DMGs in the public release repository.

Install Moeka with:

```sh
brew tap MoekaProject/moeka
brew install --cask moekaproject/moeka/moeka
```

If Homebrew reports an untrusted tap, review this repository, then run
`brew trust moekaproject/moeka` and retry the installation.

Upgrade an existing installation with:

```sh
brew update
brew upgrade --cask --greedy moekaproject/moeka/moeka
```

`--greedy` includes this cask even though Moeka also supports in-app updates.
The cask installs `Moeka.app`; it does not install a `moeka` terminal command.

## Maintainer publishing

Official binaries are built, signed and notarized locally, then published in
[`MoekaProject/community`](https://github.com/MoekaProject/community/releases).
The source repository's local `make publish vX.Y.Z` subsequently updates this tap.
There is no scheduled or manually dispatched GitHub Actions publisher.

To sync an already published stable release, maintainers run these commands in
the private source repository:

```sh
make homebrew-check TAG=vX.Y.Z
make publish-homebrew TAG=vX.Y.Z
```

The helper downloads both public DMGs, verifies their sizes and SHA-256 digests
against GitHub release metadata, and updates only the cask version and checksums
in a fresh clone of this tap. Drafts, prereleases, downgrades, same-version
checksum changes and concurrent push conflicts are refused. Matching versions
and hashes are a verified no-op. Only public tap history is pushed.

If the tap update fails after the application release succeeds, retry only
`make publish-homebrew`; do not rebuild or republish the application release.
Local Git authentication must allow writes to this tap; no Actions secrets are
required. `livecheck` detects upstream stable versions, but does not publish them:

```sh
brew livecheck --cask moekaproject/moeka/moeka
```
