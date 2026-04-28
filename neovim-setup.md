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
- Rust toolchain via `msrustup` + `cargo`

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

# tree-sitter-cli (Azure Linux 3 has glibc 2.38, Mason's pre-built binary needs 2.39)
cargo install tree-sitter-cli
```

**Important**: Mason (LazyVim's tool manager) downloads a pre-built `tree-sitter` binary that requires glibc 2.39+. Azure Linux 3 ships glibc 2.38, so treesitter parsers will fail to compile. Building `tree-sitter-cli` from source via cargo links against the system glibc and fixes this. If Mason installs its own copy, remove it:

```zsh
rm -f ~/.local/share/nvim/mason/bin/tree-sitter
```

## Step 3: Install rust-analyzer component

If using `msrustup` (Microsoft internal Rust toolchain), the `rust-analyzer` binary at `~/.cargo/bin/rust-analyzer` is a shim that delegates to the toolchain. You must install the component:

```zsh
msrustup component add rust-analyzer
rust-analyzer --version  # should print version, not an error
```

## Step 4: Install LazyVim starter config

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

## Step 5: Enable Rust extra

```zsh
cat > ~/.config/nvim/lua/plugins/rust.lua << 'EOF'
return {
  { import = "lazyvim.plugins.extras.lang.rust" },
}
EOF
```

This enables: rust-analyzer LSP, crates.nvim, DAP debugging support.

## Step 6: rust-analyzer config

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
                 cfgs = { "testbuild" },
               },
               checkOnSave = {
                 command = "clippy",
                 extraArgs = { "--target-dir", "/tmp/ra-check" },
               },
               procMacro = { enable = true },
               lruCapacity = 100,
             },
           },
         },
       },
     },
   },
}
EOF
```

**Key settings**:
- `--target-dir /tmp/ra-check`: Prevents RA's clippy from locking `target/` during manual cargo builds
- `cfgs = { "testbuild" }`: Makes `#[cfg(testbuild)]` code active in the editor (testbuild = debug/test builds in Orion)
- `lruCapacity = 100`: Keeps 100 parsed syntax trees in RAM (tune based on workspace size)
- `procMacro = { enable = true }`: Enables proc-macro expansion for accurate analysis

## Step 7: Disable AI completion

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

## Step 8: WSL clipboard integration

```zsh
cat > ~/.config/nvim/lua/plugins/clipboard.lua << 'EOF'
return {
  {
    "LazyVim/LazyVim",
    opts = function()
      vim.opt.clipboard = "unnamedplus"
      vim.g.clipboard = {
        name = "WslClipboard",
        copy = {
          ["+"] = "clip.exe",
          ["*"] = "clip.exe",
        },
        paste = {
          ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
          ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        },
        cache_enabled = 0,
      }
    end,
  },
}
EOF
```

This makes `y` (yank) and `p` (paste) work with the Windows clipboard via WSL.

## Step 9: tmux config

```zsh
cat > ~/.tmux.conf << 'EOF'
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
set -g mouse on
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Resize panes with Alt + arrow keys (5 cells per press)
bind -n M-Up resize-pane -U 5
bind -n M-Down resize-pane -D 5
bind -n M-Left resize-pane -L 5
bind -n M-Right resize-pane -R 5
EOF
```

**tmux basics**:
- `Ctrl-a %` — vertical split
- `Ctrl-a "` — horizontal split
- `Ctrl-a arrow` — switch between panes
- `Alt+arrow` — resize panes
- `Ctrl-a d` — detach (session keeps running)
- `tmux attach -t dev` — re-attach

Typical layout: neovim (80% left), copilot-cli (20% right).

```zsh
tmux new -s dev
# Then Ctrl-a % to split, resize with Alt+Left/Right
```

## Step 10: First launch

```zsh
nvim
# Plugins auto-install on first launch (~1-2 min)
# Treesitter parsers auto-install
# Open a .rs file to trigger rust-analyzer indexing
# First RA index of a large workspace (70+ crates) takes several minutes
```

---

## Key Bindings — VS Code to Neovim Cheatsheet

| VS Code | Action | Neovim (LazyVim) |
|---|---|---|
| Ctrl+Click | Go to definition | `gd` |
| Shift+F12 | Find all references | `grr` |
| F12 | Go to implementation (traits) | `gI` |
| Ctrl+P | Find file by name | `<Space>ff` |
| Ctrl+Shift+F | Search in all files | `<Space>sg` |
| Ctrl+Shift+O | Go to symbol in file | `<Space>ss` |
| Ctrl+T | Go to symbol in workspace | `<Space>sS` |
| Ctrl+G | Go to line | `:<number>` then Enter |
| Ctrl+Tab | Switch between open files | `<Space>,` (buffer picker) or `H`/`L` (prev/next) |
| Ctrl+. | Code actions | `<Space>ca` |
| F2 | Rename symbol | `<Space>cr` |
| Ctrl+` | Terminal | `<Space>ft` |
| Ctrl+B | Toggle sidebar | `<Space>e` (file explorer) |
| Ctrl+Shift+P | Command palette | `<Space>` then wait (which-key shows all commands) |
| Hover | Show docs/type info | `K` |

**Note on `gr` (references)**: `gr` opens a sub-menu. Press `grr` (gr then r) for find-all-references. `gI` only works on trait implementations, not regular functions.

### Auto-formatting features (no config needed)
- **Auto-close brackets**: Type `{` and `}` is inserted automatically (mini.pairs plugin)
- **Auto-indent**: Cursor is indented inside the block
- **Format on save**: rust-analyzer formats with `rustfmt` on save

---

## Neovim Config File Summary

All config files are checked in under `config/nvim/` in this repo. To deploy:

```zsh
# Back up existing config
mv ~/.config/nvim{,.bak} 2>/dev/null

# Symlink or copy from this repo
cp -r /path/to/my-dev-env/config/nvim ~/.config/nvim
```

Key files under `config/nvim/lua/plugins/`:

| File | Purpose |
|---|---|
| `rust.lua` | Enables LazyVim Rust extra (rust-analyzer, crates.nvim, DAP) |
| `rust-overrides.lua` | rust-analyzer settings (target dir, testbuild cfg, lruCapacity, procMacro) |
| `disable-ai.lua` | Disables Copilot AI suggestions, keeps LSP completion only |
| `clipboard.lua` | WSL clipboard integration via clip.exe / powershell.exe |
| `gitsigns.lua` | Enables inline git blame on every line (GitLens-style) |
| `catppuccin.lua` | Catppuccin color scheme with gitsigns integration |
| `blink-cmp.lua` | Completion engine config |
| `lang-python-c.lua` | Python and C language extras |
| `search.lua` | Search/telescope customization |

---

## Troubleshooting

### rust-analyzer crashes on startup (exit code 2)
The `rust-analyzer` binary is an msrustup shim. Install the component:
```zsh
msrustup component add rust-analyzer
```

### Treesitter parsers fail to compile
Mason's pre-built `tree-sitter` binary requires glibc 2.39+. Install from cargo:
```zsh
cargo install tree-sitter-cli
rm -f ~/.local/share/nvim/mason/bin/tree-sitter
```

### `#[cfg(testbuild)]` code appears inactive/grayed out
Add `cfgs = { "testbuild" }` to rust-analyzer cargo settings (already in the config above).

### `gd` goes to `use` statement instead of actual definition
rust-analyzer is still indexing. Wait for it to finish (check statusline progress). Use `:checkhealth lsp` to verify RA status.

### `:LspInfo` not found
Removed in Neovim 0.12+. Use `:checkhealth lsp` or:
```vim
:lua print(vim.inspect(vim.lsp.get_clients()))
```
