# Neovim + Rust Development Setup on Azure Linux 3

Terminal-first development workflow: **Neovim + lazygit + Copilot CLI**, all in tmux.

## Why Neovim over VS Code + WSL Extension

### VS Code + WSL Extension
- **Pros**: Zero-config rust-analyzer, integrated debugger (CodeLLDB), extensions marketplace, familiar UI
- **Cons**: Heavyweight (2-4GB RAM for server + rust-analyzer), context-switching between terminal and editor, occasional WSL reconnect issues, mouse-dependent workflows, file watcher limits on large workspaces

### Neovim in Terminal
- **Pros**: Zero context-switch (editor + lazygit + copilot-cli in same terminal), lightweight (~50% less RAM), instant startup, keyboard-centric composable commands, fully customizable via Lua
- **Cons**: Steep learning curve (2-4 weeks to reach VS Code parity), initial setup cost, DAP debugging less polished than VS Code, visual merge conflicts harder

### Verdict
If you're already living in the terminal with copilot-cli and lazygit, neovim eliminates the last reason to alt-tab to VS Code.

---

## Prerequisites

Already available on the dev box:
- `gcc`, `make`, `cmake` — needed by treesitter for parser compilation
- `tmux 3.4` — terminal multiplexer
- `lazygit` — TUI git client
- Rust toolchain via `rustup` + `cargo`

## Step 1: Install Neovim (pre-built binary)

Azure Linux 3 `tdnf` repos don't have neovim. Install from GitHub releases:

```zsh
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm nvim-linux-x86_64.tar.gz
```

Add to PATH in `~/.zprofile` (not `.zshrc` — keep PATH exports in zprofile):

```zsh
echo 'export PATH="/opt/nvim-linux-x86_64/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile
nvim --version | head -1
```

## Step 2: Install dependencies

```zsh
# ripgrep (needed by Telescope grep)
cargo install ripgrep

# fd (needed by Telescope find files)
npm install -g fd-find
```

## Step 3: Install LazyVim starter config

```zsh
# Back up existing config if any
mv ~/.config/nvim{,.bak} 2>/dev/null
mv ~/.local/share/nvim{,.bak} 2>/dev/null
mv ~/.local/state/nvim{,.bak} 2>/dev/null
mv ~/.cache/nvim{,.bak} 2>/dev/null

# Clone LazyVim starter
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

## Step 4: Enable Rust extra

```zsh
cat > ~/.config/nvim/lua/plugins/rust.lua << 'EOF'
return {
  { import = "lazyvim.plugins.extras.lang.rust" },
}
EOF
```

This enables: rust-analyzer LSP, crates.nvim, DAP debugging support.

## Step 5: rust-analyzer config

```zsh
cat > ~/.config/nvim/lua/plugins/rust-overrides.lua << 'EOF'
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                buildScripts = { enable = true },
              },
              checkOnSave = {
                command = "clippy",
                -- Separate target dir so RA doesn't fight cargo builds for the target/ lock
                extraArgs = { "--target-dir", "/tmp/ra-check" },
              },
              procMacro = { enable = true },
            },
          },
        },
      },
    },
  },
}
EOF
```

**Key detail**: `--target-dir /tmp/ra-check` prevents rust-analyzer's check-on-save clippy from locking the same `target/` directory as your manual `cargo build` / `cargo nextest run` commands.

## Step 6: Disable AI completion

LazyVim ships with Copilot AI suggestions by default. Disable them to keep only rust-analyzer LSP completion (types, methods, traits, fields):

```zsh
cat > ~/.config/nvim/lua/plugins/disable-ai.lua << 'EOF'
return {
  { "zbirenbaum/copilot.lua", enabled = false },
  { "zbirenbaum/copilot-cmp", enabled = false },
  { "CopilotC-Nvim/CopilotChat.nvim", enabled = false },
}
EOF
```

## Step 7: tmux config

```zsh
cat >> ~/.tmux.conf << 'EOF'
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
set -g mouse on
set -g prefix C-a
unbind C-b
bind C-a send-prefix
EOF
```

Typical session layout:
```
tmux new -s dev
# Ctrl-a %  → vertical split (nvim left, copilot-cli right)
# Ctrl-a "  → horizontal split in right pane (lazygit bottom-right)
```

## Step 8: First launch

```zsh
nvim
# Plugins auto-install on first launch (~1-2 min)
# Treesitter parsers auto-install
# Open a .rs file to trigger rust-analyzer indexing
```

---

## Key Bindings — VS Code to Neovim Cheatsheet

| VS Code | Action | Neovim (LazyVim) |
|---|---|---|
| Ctrl+Click | Go to definition | `gd` |
| Shift+F12 | Find all references | `gr` |
| F12 | Go to implementation | `gI` |
| Ctrl+P | Find file by name | `<Space>ff` |
| Ctrl+Shift+F | Search in all files | `<Space>sg` |
| Ctrl+G | Go to line | `:<number>` then Enter |
| Ctrl+Tab | Switch between open files | `<Space>,` (buffer picker) or `H`/`L` (prev/next) |
| Ctrl+. | Code actions | `<Space>ca` |
| F2 | Rename symbol | `<Space>cr` |
| Ctrl+` | Terminal | `<Space>ft` |
| Ctrl+B | Toggle sidebar | `<Space>e` (file explorer) |
| Ctrl+Shift+P | Command palette | `<Space>` then wait (which-key shows all commands) |

### Auto-formatting features (no config needed)
- **Auto-close brackets**: Type `{` and `}` is inserted automatically (mini.pairs plugin)
- **Auto-indent**: Cursor is indented inside the block
- **Format on save**: rust-analyzer formats with `rustfmt` on save

---

## Neovim Config File Summary

All files live under `~/.config/nvim/lua/plugins/`:

| File | Purpose |
|---|---|
| `rust.lua` | Enables LazyVim Rust extra (rust-analyzer, crates.nvim, DAP) |
| `rust-overrides.lua` | rust-analyzer settings (separate target dir for check-on-save) |
| `disable-ai.lua` | Disables Copilot AI suggestions, keeps LSP completion only |
