cask "lyrimuse" do
  version "1.5.0"
  sha256 "7c6196f3c77d11fbe23cebefce80e386b8d134eb4cd864ad498042b3a0d384e2"

  url "https://github.com/Yudaotor/lyrimuse/releases/download/v#{version}/Lyrimuse-v#{version}-macos.zip"
  name "Lyrimuse"
  desc "Real-time, word-synced desktop lyrics for Apple Music and others"
  homepage "https://github.com/Yudaotor/lyrimuse"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma
  # The zip this cask installs is the arm64-only primary asset -- Intel Macs need the
  # separate -intel universal build from the Releases page, which Homebrew has no way to
  # pick automatically here. Without this an Intel install "succeeds" and then the app
  # simply refuses to launch. Every release up to v1.2.0 was arm64-only too, and this
  # cask claimed nothing about architecture the whole time.
  depends_on arch: :arm64

  app "Lyrimuse.app"

  # Lyrimuse ships ad-hoc signed, not notarized (no paid Apple Developer ID --
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
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Lyrimuse.app"],
                   sudo: false
  end

  zap trash: [
    "~/.config/lyrimuse",
    "~/Library/LaunchAgents/com.lyrimuse.collector.plist",
    "~/Library/LaunchAgents/me.yudaotor.lyrimuse.plist",
    "~/Library/Logs/lyrimuse.log",
    "~/Library/Preferences/me.yudaotor.lyrimuse.plist",
  ]
end
