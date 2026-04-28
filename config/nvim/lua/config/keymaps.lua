-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Navigate quickfix results (after sending telescope results to qflist)
vim.keymap.set("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix result" })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>zz", { desc = "Prev quickfix result" })

-- Toggle Trouble quickfix panel
vim.keymap.set("n", "<leader>sq", "<cmd>Trouble qflist toggle<cr>", { desc = "Search results (Trouble)" })

-- LSP rename (global symbol update)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
