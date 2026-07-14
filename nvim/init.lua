-- TODO:
-- - LSPs
--   - mason setup?
-- - better undo / cross-session
-- - autocomplete that actually works + doesn't break snacks.picker
-- - git integration
-- - spelling dictionary (nvim, neovim, github, etc)
-- - some sort of autoupdate? (lua: `vim.pack.update` and `vim.pack.del()`)
-- - wrap with `()`

--- for convenience
local vim = vim
local o = vim.opt
local g = vim.g
local function tableMerge(...)
  -- https://www.reddit.com/r/lua/comments/rtiedd/comment/o9d8xlb
  local result = {}
   for _, t in ipairs({...}) do
      for _, v in ipairs(t) do
        table.insert(result, v)
      end
  end
  return result
end
-- map defined from Snacks
local isWork = os.getenv("USER") == "stevenc"
vim.notify("isWork: " .. (isWork and "yes" or "no"))
--- globals
g.mapleader = " "
g.maplocalleader = ","
-- disable complaints
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
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
o.spell = true

vim.cmd[[colorscheme catppuccin]]
g.transparent_enabled = true
vim.api.nvim_set_hl(0, "LineNr", { fg = "#aaaaaa" })

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
  _gh("xiyaowong/transparent.nvim"), -- transparency!!
  _gh("lewis6991/gitsigns.nvim"), -- git integration
  _gh("folke/snacks.nvim"), -- snacks: lots of things
  _gh("folke/which-key.nvim"), -- keybinding help
  _gh("akinsho/toggleterm.nvim"), -- terminal library
  _gh("nvim-mini/mini.nvim"), -- mini: 45+ things
  _gh("folke/todo-comments.nvim"), -- highlight TODO, etc. in comment
})
if not isWork then
  vim.pack.add({
    _gh("wakatime/vim-wakatime"), -- wakatime integration, :WakaTimeApiKey to set up
  })
end


-- git integration
require("gitsigns").setup()


-- snacks
require("snacks").setup({
  explorer = {},
  picker = {
    layouts = {
      sidebar = {
        layout = {
          width = 30,
          min_width = 20,
        },
      }
    }
  },
  -- lazygit = {}, -- skip this as it doesn't keep the same styles
  notifier = {},
  toggle = {
    map = map, -- use the snacks.keymap function
  },
  styles = {
    notification_history = {
      keys = {
        q = "close",
        { "<esc>", "close", mode = "n" },
      },
    },
    picker
  }
})
-- https://github.com/folke/snacks.nvim/blob/main/docs/keymap.md
local map = Snacks.keymap.set
-- stolen from snacks' docs
_G.dd = function(...)
  Snacks.debug.inspect(...)
end
_G.bt = function()
  Snacks.debug.backtrace()
end
vim._print = function(_, ...)
  dd(...)
end

-- thanks to https://www.reddit.com/r/neovim/comments/1j55o9c/comment/mgny6eo/
Snacks.toggle.option("spell", { name = "󰓆 Spell Checking" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "󰖶 Wrap Long Lines" }):map("<leader>uw")
Snacks.toggle.option("list", { name = "󱁐 List (Visible Whitespace)" }):map("<leader>ul")
Snacks.toggle.diagnostics({ name = " Diagnostics" }):map("<leader>uD") -- TODO: test this
Snacks.toggle
  .new({
    id = "git_sign_column",
    name = " Git Sign Column",
    get = function()
      return require("gitsigns.config").config.signcolumn
    end,
    set = function(state)
      require("gitsigns").toggle_signs(state)
    end,
  })
  :map("<leader>ug")
Snacks.toggle
  .new({
    id = "number",
    name = " Line Numbers",
    get = function()
      return vim.wo.number
    end,
    set = function(state)
      -- toggles relnum with num
      -- if state then
      --   vim.wo.relativenumber = true
      -- else
      --   vim.wo.relativenumber = false
      -- end
      vim.wo.number = state
    end,
  })
  :map("<leader>un")
Snacks.toggle
  .new({
    id = "relativenumber",
    name = " Relative Line Numbers",
    get = function()
      return vim.wo.relativenumber
    end,
    set = function(state)
      -- if no nums shown, enable them too
      if vim.wo.number == false then
        vim.wo.number = true
      end
      vim.wo.relativenumber = state
    end,
  })
  :map("<leader>uN")
Snacks.toggle
  .new({
    id = "format_on_save",
    name = "󰊄 Format on Save (global)",
    get = function()
      return not vim.g.disable_autoformat
    end,
    set = function(state)
      vim.g.disable_autoformat = not state
    end,
  })
  :map("<leader>uf")
  Snacks.toggle
    .new({
      id = "format_on_save_buffer",
      name = "󰊄 Format on Save (buffer)",
      get = function()
        return not vim.b.disable_autoformat
      end,
      set = function(state)
        vim.b.disable_autoformat = not state
      end,
  })
  :map("<leader>uF")
Snacks.toggle
  .new({
    id = "inline_hints",
    name = " LSP Inline Hints",
    get = vim.lsp.inlay_hint.is_enabled,
    set = function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end,
  })
  :map("<leader>ui") -- TODO: test this
Snacks.toggle
  .new({
    id = "inline_hints_end",
    name = " LSP Inline Hints at Line End",
    get = function()
      return vim.g.snacks_toggle_lsp_hints_end
    end,
    set = function()
      require("lsp-endhints").toggle()
      vim.g.snacks_toggle_lsp_hints_end = not vim.g.snacks_toggle_lsp_hints_end
    end,
  })
  :map("<leader>uI") -- TODO: test this
Snacks.toggle
  .new({
    id = "transparency",
    name = "Transparency",
    get = function() return g.transparent_enabled end,
    set = function() require("transparent").toggle() end,
  }):map("<leader>ut") -- transparency!

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
map("n", "<leader>fn", Snacks.notifier.show_history, { desc = "Notification History" })
map("n", "<leader>e", function() require("snacks").explorer() end, { desc = "Toggle Explorer" })
-- map("n", "<leader>gg", function() require("snacks").lazygit() end, { desc = "Open Lazygit" })
--

-- which-key for showing mappings
local wk = require("which-key")
wk.setup({
  preset = "helix",
})
wk.add({
  { "<leader>f", group = "find" }, -- group
  { "<leader>g", group = "git" }, -- group
  { "<leader>t", group = "terminal" }, -- group
  { "<esc><esc>", hidden = true}, -- hide popup for <esc><esc> -> :noh
})

-- toggleterm
require("toggleterm").setup({
  direction = "float"
})
map("n", "<leader>tr", ":ToggleTerm direction=vertical<cr>", { desc = "right" })
map("n", "<leader>tb", ":ToggleTerm direction=horizontal<cr>", { desc = "below" })
map("n", "<leader>tf", ":ToggleTerm direction=float<cr>", { desc = "floating" })
map("n", "<leader>tt", ":ToggleTerm direction=float<cr>", { desc = "floating" })
local Terminal  = require('toggleterm.terminal').Terminal
local btop = Terminal:new({ cmd = "btop", hidden = true })
map("n", "<leader>tp", function() btop:toggle() end, { desc = "`btop`" })
local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })
map("n", "<leader>gg", function() lazygit:toggle() end, { desc = "`lazygit`" })

-- mini!
local miniicons = require("mini.icons")
miniicons.setup()
miniicons.mock_nvim_web_devicons()

-- todo-comments
require("todo-comments").setup()

-- configure LSPs

--
---


--- misc keybinds
-- map("n", "<C-q>", ":q<cr>", {desc = "Quit"})
map("n", "<leader>q", ":q<cr>", {desc = "Quit"})
-- map("n", "<C-w>", ":w<cr>", {desc = "Save"})
map("n", "<leader>w", ":w<cr>", {desc = "Save"})
map("n", "<esc><esc>", ":noh<cr>", {desc = ":noh"})
map("n", "U", "<C-r>", {desc = "Redo"})
map("n", "<leader>/", "gcc", {desc = "comment", remap = true}) -- add remap as otherwise can't pass motions directly
map("v", "<leader>/", "gc", {desc = "comment", remap = true}) -- add remap as otherwise can't pass motions directly
map("n", "<leader>ch", ":checkhealth<cr>", {desc = "Check Health"})
map("n", "<leader>]", ":vsp<cr>", {desc = "Vertical split"})
map("n", "<leader>[", ":sp<cr>", {desc = "Horizontal split"})
---
