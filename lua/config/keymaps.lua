-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap.set
local opts = { silent = true }

keymap("i", "jk", "<ESC>", opts)
keymap("n", "<Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
keymap("n", "<Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
keymap("n", "<Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
keymap("n", "<Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
