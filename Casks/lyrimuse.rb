cask "lyrimuse" do
  # The primary "-macos" asset is arm64-only; Intel Macs get the separate "-intel"
  # universal build. Without this split an Intel install used to "succeed" and then
  # the app simply refused to launch (this cask was arm64-only until v1.5.0).
  arch intel: "-intel"

  version "1.13.0"
  sha256 arm:   "4b7dfa5fc193754a7c454887e8f2d6a42280bf55d687372b6e6389b14a19fc8e",
         intel: "defbebe32e3e97ae73a5c764df0a7988f3d6dd38ecc39ec6518bd7877a2b4cca"

  url "https://github.com/Yudaotor/lyrimuse/releases/download/v#{version}/Lyrimuse-v#{version}-macos#{arch}.zip"
  name "Lyrimuse"
  desc "Word-synced desktop lyrics for Apple Music, Spotify, QQ Music and NetEase"
  homepage "https://github.com/Yudaotor/lyrimuse"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The app updates itself via Sparkle (appcast on GitHub Releases), so a brew
  # upgrade isn't the only way users stay current.
  auto_updates true
  depends_on macos: :sonoma

  app "Lyrimuse.app"

  # Lyrimuse is signed with the project's own certificate, not notarized (no paid Apple Developer ID --
  # see the README's "Getting Started" section for the full rationale). Homebrew
  # Cask deliberately re-applies com.apple.quarantine to installed apps by
  # default (mimicking a real browser download, for security transparency --
  # this is NOT something `brew install --cask` skips on its own, verified by
  # reading cask/download.rb/quarantine.rb directly rather than assuming), so
  # without this postflight step the app would still hit the exact same
  # Gatekeeper "unidentified developer" prompt on first launch that a manual
  # zip download does. This does the same one-time `xattr -dr` the README's
  # Option A tells users to run themselves -- just automatically, since this
  # is the maintainer's own personal tap and the trust decision is identical
  # either way.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/Lyrimuse.app"]
  end

  # The background engine is a KeepAlive launch agent: left loaded, launchd keeps
  # relaunching a binary that's no longer there. The app only reinstalls the job
  # when it launches, so unloading it before quitting the app is safe.
  uninstall launchctl: "com.lyrimuse.collector",
            quit:      "me.yudaotor.lyrimuse"

  # Account credentials live in one login-keychain item, keyed by the data
  # folder. `security` exits 44 when there is none, which isn't a failure here.
  zap script: {
        executable:   "/usr/bin/security",
        args:         ["delete-generic-password", "-s", "me.yudaotor.lyrimuse.credentials",
                       "-a", "#{Dir.home}/Library/Application Support/me.yudaotor.lyrimuse"],
        must_succeed: false,
      },
      trash:  [
        "~/.config/lyrimuse",
        "~/.config/lyrimuse-backups/*-song-entity",
        "~/.config/lyrimuse-backups/*-song-entity-manual",
        "~/.config/lyrimuse.leftover-*",
        "~/.config/lyrimuse.migrated",
        "~/Library/Application Support/me.yudaotor.lyrimuse",
        "~/Library/Caches/me.yudaotor.lyrimuse",
        "~/Library/HTTPStorages/me.yudaotor.lyrimuse",
        "~/Library/HTTPStorages/me.yudaotor.lyrimuse.binarycookies",
        "~/Library/LaunchAgents/com.lyrimuse.collector.plist",
        "~/Library/LaunchAgents/me.yudaotor.lyrimuse.plist",
        "~/Library/Logs/Lyrimuse",
        "~/Library/Logs/lyrimuse-app.log*",
        "~/Library/Logs/lyrimuse-main-thread-stall.txt",
        "~/Library/Logs/lyrimuse.log*",
        "~/Library/Preferences/me.yudaotor.lyrimuse.plist",
        "~/Library/WebKit/me.yudaotor.lyrimuse",
      ],
      rmdir:  "~/.config/lyrimuse-backups"
end
