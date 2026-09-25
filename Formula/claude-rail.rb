# Homebrew formula for Claude Rail. Lives in the tap dhamija/claude-rail (repo homebrew-claude-rail):
#   brew tap dhamija/claude-rail            # public tap; or, while the code repo is private:
#   brew tap dhamija/claude-rail git@github.com:dhamija/homebrew-claude-rail.git
#   brew trust --tap dhamija/claude-rail      # Homebrew 6: third-party taps load only once trusted
#   brew install --HEAD claude-rail && claude-rail setup
# brew puts the checkout under libexec and the CLIs on PATH; `claude-rail setup` then does what the
# installer does (deploys ~/.claude-rail, builds the Electron app, installs the skills and commands
# into ~/.claude, enables the hooks, makes the Dock launcher). `brew upgrade --fetch-HEAD claude-rail`
# followed by `claude-rail setup` updates; `claude-rail update` runs both.
class ClaudeRail < Formula
  desc "Side rail, session grid and companion skills for Claude Code on macOS"
  homepage "https://github.com/dhamija/claude-rail"
  license "MIT"
  # The code repo is private for now: HEAD over SSH works for anyone with access. When a release
  # tarball exists, add `url` + `sha256` here and the tap works without SSH.
  url "https://github.com/dhamija/claude-rail-releases/releases/download/v0.1.3/claude-rail-0.1.3.tar.gz"
  sha256 "ae6ec14d9c52d2b8ea9231df54b6851117327c5990f58182455c10d1c219cb72"
  version "0.1.3"
  head "git@github.com:dhamija/claude-rail.git", using: :git, branch: "main"

  depends_on "node"
  depends_on "python@3.13"
  depends_on :macos

  def install
    # Only the runtime files go into the keg. The app's dependencies (Electron, node-pty, xterm)
    # are built by the first launch, in ~/.claude-rail: Homebrew rewrites every Mach-O binary it
    # finds in a keg, and Electron's framework cannot take that (it fails, and could be left half
    # modified), so prebuilt binaries must stay out of here.
    libexec.install Dir["*"]
    (bin/"claude-rail").write_env_script libexec/"bin/claude-rail", PATH: "#{Formula["node"].opt_bin}:$PATH"
    (bin/"claude-rail-app").write_env_script libexec/"bin/claude-rail-app", PATH: "#{Formula["node"].opt_bin}:$PATH"
  end

  def caveats
    <<~EOS
      Start it once to finish:
        claude-rail-app --grid
      The first launch deploys ~/.claude-rail and builds the app's dependencies there (about a
      minute: Electron is downloaded), installs the skills and commands into ~/.claude, enables
      the hooks and creates the Dock launcher. Homebrew cannot write there itself.
      Later: `claude-rail update`.
    EOS
  end

  test do
    assert_match "claude-rail", shell_output("#{bin}/claude-rail --help 2>&1", 1)
  end
end
