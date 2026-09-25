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
  url "https://github.com/dhamija/claude-rail-releases/releases/download/v0.1.0/claude-rail-0.1.0.tar.gz"
  sha256 "5a3d2b0b3c5165abf0fa3f80cec8af32ff44388d143911dab9c7dd8119ac1af2"
  version "0.1.0"
  head "git@github.com:dhamija/claude-rail.git", using: :git, branch: "main"

  depends_on "node"
  depends_on "python@3.13"
  depends_on :macos

  def install
    libexec.install Dir["*"]
    # The app's dependencies (Electron, node-pty, xterm) are built here, where the sandbox allows
    # it; the first launch only has to copy them into place.
    ENV["PATH"] = "#{Formula["node"].opt_bin}:#{ENV["PATH"]}"
    system "bash", libexec/"bin/claude-rail-deps", libexec/"app"
    system "node", "build.js" unless (libexec/"app/dist/rail.js").exist?
    (bin/"claude-rail").write_env_script libexec/"bin/claude-rail", PATH: "#{Formula["node"].opt_bin}:$PATH"
    (bin/"claude-rail-app").write_env_script libexec/"bin/claude-rail-app", PATH: "#{Formula["node"].opt_bin}:$PATH"
  end

  def caveats
    <<~EOS
      Start it once to finish:
        claude-rail-app --grid
      The first launch deploys ~/.claude-rail, installs the skills and commands into ~/.claude,
      enables the hooks and creates the Dock launcher (Homebrew cannot write there itself).
      Later: `claude-rail update`.
    EOS
  end

  test do
    assert_match "claude-rail", shell_output("#{bin}/claude-rail --help 2>&1", 1)
  end
end
