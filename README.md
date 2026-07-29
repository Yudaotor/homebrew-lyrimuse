# homebrew-lyrimuse

Homebrew Cask tap for [Lyrimuse](https://github.com/Yudaotor/lyrimuse), a
menu-bar app that shows real-time, word-synced desktop lyrics for Apple Music
or QQ Music on macOS.

```bash
brew tap yudaotor/lyrimuse
brew install --cask lyrimuse
```

Lyrimuse ships ad-hoc signed (no paid Apple Developer ID) — see the
[main repo's README](https://github.com/Yudaotor/lyrimuse#readme) for why.
Installing via this tap clears the one-time Gatekeeper quarantine
automatically, so there's no manual step after `brew install` finishes.
