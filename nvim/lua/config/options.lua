local o, g = vim.opt, vim.g
local util = require "config.util"

g.mapleader = " "
g.maplocalleader = ","

-- disable complaints
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0

--- text editing settings
-- clipboard!!
if not util.is_work then
  g.clipboard = "osc52" -- use terminal clipboard
end
o.clipboard = "unnamedplus" -- default to it

-- indentation || spaces are the best
-- guess-indent will set these anyway
o.tabstop = 2
o.softtabstop = 2
o.expandtab = true
o.shiftwidth = 0 -- forces ts/sts to be used when <tab> pressed
o.ignorecase = true
o.infercase = true
o.spelloptions = "camel"
o.virtualedit = "block"

--- UI/UX!
o.number = true
o.relativenumber = true
o.signcolumn = "yes" -- set to yes to prevent shifting once gitsigns loads
o.cursorline = true

o.list = true
o.listchars = "trail:·,tab:-»"
o.fillchars = "eob: " -- Don't show `~` outside of buffer
o.spell = true

vim.cmd [[colorscheme catppuccin]]
g.transparent_enabled = true
-- add `NormalFloat` to list of groups to set to transparent
-- (must be set before transparent.nvim loads, hence living here)
g.transparent_groups = vim.list_extend(g.transparent_groups or {}, {
  "NormalFloat",
  "FloatBorder",
  -- hide completion background
  "Pmenu",
  "PmenuSel",
  "PmenuSbar",
  "PmenuThumb", -- native popups
  "MiniCompletionActiveParameter",
  -- hide tabline colors: base tab style, BG
  "TabLine",
  "TabLineFill",
  -- hide code and h3+ background:
  "RenderMarkdownCode",
  "RenderMarkdownH3Bg",
  "RenderMarkdownH4Bg",
  "RenderMarkdownH5Bg",
  "RenderMarkdownH6Bg",
})
vim.api.nvim_set_hl(0, "LineNr", { fg = "#999999" })

-- wrap settings:
o.breakindent = true
o.breakindentopt = "shift:3" -- let's try 3 so it's in-between and jarring

o.undofile = true

o.splitbelow = true
o.splitright = true
o.foldmethod = "indent"
o.foldlevel = 10
