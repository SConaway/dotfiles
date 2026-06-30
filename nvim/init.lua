-- TODOs: 
-- - LSPs
--   - mason setup?
-- - better undo / cross-session
-- - autocomplete that actually works + doesn't break snacks.picker
-- - spellcheck for md/txt
-- - highlight `TODO:`
-- - git integration
-- - some sort of autoupdate? (lua: `vim.pack.update`)
-- - wakatime

--- for convenience
local vim = vim
local o = vim.opt
local g = vim.g
local map = vim.keymap.set

--- globals
g.mapleader = " "
g.maplocalleader = ","
---

--- text editing settings
-- clipboard!!
g.clipboard = "osc52" -- use terminal clipboard
o.clipboard = "unnamedplus" -- default to it

-- indentation || spaces are the best
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 0 -- forces ts/sts to be used when <tab> pressed
o.expandtab = true
o.ignorecase = true
--- UI/UX!
o.number = true
o.relativenumber = true
o.signcolumn = "yes" -- set to yes to prevent shifting once gitsigns loads

o.list = true
o.listchars = "trail:·,tab:» "

vim.cmd[[colorscheme catppuccin]]
-- Clear background for transparency
-- https://github.com/neovim/neovim/blob/master/runtime/colors/catppuccin.vim
vim.api.nvim_set_hl(0, "Normal",       { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC",     { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat",  { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder",  { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn",   { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLine",   { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLineNC",   { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer",  { bg = "none" })
vim.api.nvim_set_hl(0, "LineNr",       { fg = "#aaaaaa" })

-- wrap settings: 
o.breakindent = true
o.breakindentopt = "shift:3" -- let's try 3 so it's in-between and jarring

-- tame auto-comment (`formatoptions`)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r" })
    -- o = auto-comment on `o`/`O` in normal mode
    -- r = auto-comment on <Enter> in insert mode
  end,
})
---

--- configure plugins
-- helper function for gh urls
local _gh = function(x) return "https://github.com/" .. x end
-- install listed plugins
-- does not configure them
vim.pack.add({
  -- _gh("folke/lazydev.nvim") -- TODO: pending LSP setup
  _gh("lewis6991/gitsigns.nvim"), -- git integration
  _gh("folke/snacks.nvim"), -- misc UI things
  _gh("folke/which-key.nvim"), -- keybinding help
})


-- git integration
require("gitsigns").setup()


-- snacks
require("snacks").setup({
  explorer = {},
})
map("n", "<leader>fC", Snacks.picker.commands, { desc = "Find Commands" })
map("n", "<leader>fc", Snacks.picker.grep_word, { desc = "Find Word" })
map("n", "<leader>fd", Snacks.picker.diagnostics, { desc = "Find Diagnostics" })
map("n", "<leader>ff", Snacks.picker.files, { desc = "Find Files" })
map("n", "<leader>fh", Snacks.picker.help, { desc = "Find Help" })
map("n", "<leader>fk", Snacks.picker.keymaps, { desc = "Find Keymaps" })
map("n", "<leader>fm", Snacks.picker.man, { desc = "Find Manpages" })
map("n", "<leader>ft", Snacks.picker.colorschemes, { desc = "Find Themes" })
map("n", "<leader>fu", Snacks.picker.undo, { desc = "Find Undo History" })
map("n", "<leader>fw", Snacks.picker.grep, { desc = "Find Words" })
map("n", "<leader>e", function() require("snacks").explorer() end, { desc = "Toggle Explorer" })
--

require("which-key").setup({
  preset = "modern",
})

-- configure LSPs

--
---


--- misc keybinds
map("n", "<C-q>", ":q<cr>", {desc = "Quit"})
map("n", "<leader>q", ":q<cr>", {desc = "Quit"})
map("n", "<C-w>", ":w<cr>", {desc = "Save"})
map("n", "<leader>w", ":w<cr>", {desc = "Save"})
map("n", "<esc><esc>", ":noh<cr>", {desc = ":noh"})
map("n", "U", "<C-r>", {desc = "Redo"})
map("n", "<leader>/", "gcc", {desc = "comment", remap = true}) -- add remap as otherwise can't pass motions directly
map("v", "<leader>/", "gc", {desc = "comment", remap = true}) -- add remap as otherwise can't pass motions directly
---
