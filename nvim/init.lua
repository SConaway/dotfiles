-- TODOs: 
-- - LSPs
--   - mason setup?
-- - clipboard (osc52)
-- - highlight `TODO:`
-- - search for help
-- - keys
--   - how to see current bindings
--   - ctrl-q: quit
--   - leader q: quit
--   - leader /: comment
--   - double escape: `:noh`
-- - some sort of autoupdate? (lua: `vim.pack.update`)
-- - wakatime

-- for convenience
local vim = vim
local o = vim.opt
local g = vim.g
local map = vim.keymap.set

-- globals
g.mapleader = " "
g.maplocalleader = ","
--

-- text editing settings
-- tabs!
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 0 -- forces it to use `sts` instead
o.expandtab = true
g.clipboard = "unnamedplus"
-- UI/UX!
o.relativenumber = true
o.autocomplete = true
o.signcolumn = "auto"

o.list = true
o.listchars = "trail:·,tab:» "

-- tame auto-comment (`formatoptions`)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r" })
    -- o = auto-comment on `o`/`O` in normal mode
    -- r = auto-comment on <Enter> in insert mode
  end,
})
--

-- configure plugins
local gh = function(x) return 'https://github.com/' .. x end
vim.pack.add({
  -- gh("folke/lazydev.nvim") -- TODO: pending LSP setup
})
--

-- configure LSPs

--
