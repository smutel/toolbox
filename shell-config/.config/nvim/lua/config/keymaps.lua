-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set

-- NeoTree
map("n", "<leader><up>", "<cmd>Neotree focus<cr>", { desc = "NeoTree focus" })

-- Tabs
map("n", "<leader><tab><left>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab><right>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Buffers
map("n", "<leader>b<left>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<leader>b<right>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
