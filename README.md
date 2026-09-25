# Homebrew tap for Claude Rail

```bash
brew tap dhamija/claude-rail                    # or, while the code repo is private:
brew tap dhamija/claude-rail git@github.com:dhamija/homebrew-claude-rail.git
brew trust --tap dhamija/claude-rail
brew install claude-rail && claude-rail-app --grid   # the first launch finishes the setup
# (--HEAD builds the private main over SSH instead of the latest release)
```

The formula is mirrored from `Formula/claude-rail.rb` in the code repo (github.com/dhamija/claude-rail).
