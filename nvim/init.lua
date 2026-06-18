-- TODOs: 
-- - LSPs
--   - mason setup?
-- - clipboard (osc52)
-- - better undo / cross-session
-- - autocomplete that actually works + doesn't break snacks.picker
-- - highlight `TODO:`
-- - search for help
-- - git integration
-- - keys
--   - how to see current bindings
--   - leader /: comment
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
g.clipboard = "unnamedplus"
---

--- text editing settings
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
local gh = function(x) return "https://github.com/" .. x end
-- install listed plugins
-- does not configure them
vim.pack.add({
  -- gh("folke/lazydev.nvim") -- TODO: pending LSP setup
  gh("lewis6991/gitsigns.nvim"), -- git integration
  gh("folke/snacks.nvim"), -- misc UI things
})


-- git integration
require("gitsigns").setup()


-- snacks
require("snacks").setup()
map("n", "<leader>ff", Snacks.picker.files, { desc = "Find Files" })
map("n", "<leader>fh", Snacks.picker.help, { desc = "Find Help" })
-- map("n", "<leader>ft", Snacks.picker.themes, { desc = "Find Themes" })
map("n", "<leader>fw", Snacks.picker.grep, { desc = "Find Words" })
--

-- configure LSPs

--
---


--- misc keybinds
map("n", "<C-q>", ":q<cr>", {desc = "Quit"})
map("n", "<leader>q", ":q<cr>", {desc = "Quit"})
map("n", "<esc><esc>", ":noh<cr>", {desc = ":noh"})
map("n", "U", "<C-r>", {desc = "Redo"})
---
