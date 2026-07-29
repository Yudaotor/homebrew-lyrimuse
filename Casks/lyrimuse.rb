cask "lyrimuse" do
  version "1.1.0"
  sha256 "0723b7ed40ed4ea684ee3547c4542d66010849fa5d36cbb71ce314b7f25271b6"

  url "https://github.com/Yudaotor/lyrimuse/releases/download/v#{version}/Lyrimuse-v#{version}-macos.zip"
  name "Lyrimuse"
  desc "Real-time, word-synced desktop lyrics for Apple Music and QQ Music"
  homepage "https://github.com/Yudaotor/lyrimuse"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :sonoma"

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
    "~/Library/LaunchAgents/me.yudaotor.lyrimuse.plist",
    "~/Library/LaunchAgents/com.lyrimuse.collector.plist",
    "~/Library/Logs/lyrimuse.log",
    "~/Library/Preferences/me.yudaotor.lyrimuse.plist",
  ]
end
