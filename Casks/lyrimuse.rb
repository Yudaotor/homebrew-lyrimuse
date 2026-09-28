cask "lyrimuse" do
  # The primary "-macos" asset is arm64-only; Intel Macs get the separate "-intel"
  # universal build. Without this split an Intel install used to "succeed" and then
  # the app simply refused to launch (this cask was arm64-only until v1.5.0).
  arch intel: "-intel"

  version "1.9.0"
  sha256 arm:   "de6e04308d48369970cb23629f64f2df5a0bcd830a3bb5af47c0df6daf573e80",
         intel: "25ed99e95bdb3f34edcb1370e03a750ce974e7b8cf4a1c145f2ffced14367baf"

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

  zap trash: [
    "~/.config/lyrimuse",
    "~/Library/LaunchAgents/com.lyrimuse.collector.plist",
    "~/Library/LaunchAgents/me.yudaotor.lyrimuse.plist",
    "~/Library/Logs/lyrimuse.log",
    "~/Library/Preferences/me.yudaotor.lyrimuse.plist",
  ]
end
