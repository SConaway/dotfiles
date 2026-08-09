-- TODO:
-- - LSPs
--   - mason setup?
-- - better undo / cross-session
-- - spelling dictionary (nvim, neovim, github, etc)
-- - some sort of autoupdate? (lua: `vim.pack.update()` and `vim.pack.del()`)

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
-- vim.notify("isWork: " .. (isWork and "yes" or "no"))
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
if not isWork then
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
o.spelloptions = 'camel'
o.virtualedit = 'block'
--- UI/UX!
o.number = true
o.relativenumber = true
o.signcolumn = "yes" -- set to yes to prevent shifting once gitsigns loads
o.cursorline = true

o.list = true
o.listchars = "trail:·,tab:» "
o.fillchars = 'eob: ' -- Don't show `~` outside of buffer
o.spell = true

vim.cmd[[colorscheme catppuccin]]
g.transparent_enabled = true
-- add `NormalFloat` to list of groups to set to transparent
vim.g.transparent_groups = vim.list_extend(vim.g.transparent_groups or {}, {
  "NormalFloat", "FloatBorder",
  "Pmenu", "PmenuSel", "PmenuSbar", "PmenuThumb",  -- native popups
  "MiniCompletionActiveParameter",
})
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

o.undofile = true

o.splitbelow = true
o.splitright = true
o.foldmethod = 'indent'
o.foldlevel = 10

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
  _gh("folke/snacks.nvim"), -- snacks: search pickers, file explorer, indent guides, notifications part 1, UI toggles, statuscolumn additions
  _gh("folke/which-key.nvim"), -- keybinding help
  _gh("akinsho/toggleterm.nvim"), -- terminal library
  _gh("nvim-mini/mini.nvim"), -- mini.nvim: session resume, icons, surround, split/join, snippets, completion, autopairs, move shortcuts, cmdline completion
  _gh("folke/todo-comments.nvim"), -- highlight TODO, etc. in comment
  _gh("nmac427/guess-indent.nvim"), -- guess-indent to auto configure the indentation settings
  _gh("MunifTanjim/nui.nvim"), -- needed for noice
  _gh("folke/noice.nvim"), -- noice: new UI for messages, cmdline, popup
})
if not isWork then
  vim.pack.add({
    _gh("wakatime/vim-wakatime"), -- wakatime integration, :WakaTimeApiKey to set up
  })
end
local minimisc = require('mini.misc')
now = function(f) minimisc.safely('now', f) end
later = function(f) minimisc.safely('later', f) end
now(minimisc.setup_restore_cursor)


-- snacks
now(function()
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
      },
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "n", "i" } },
            -- <C-q> shouldn't open qflist
            ["<C-q>"] = { "close", mode = { "i", "n" } },
          }
        }
      }
    },
    indent = {
      animate = {
        enabled = false,
      },
    },
    -- lazygit = {}, -- skip this as it doesn't keep the same styles
    notifier = {}, -- combine with snacks notifier too
    toggle = {
      map = map, -- use the snacks.keymap function
    },
    statuscolumn = {
      enabled = true,
      left = { "mark", "sign" }, -- priority of signs on the left (high to low)
      right = { "fold", "git" }, -- priority of signs on the right (high to low)
      folds = {
        open = true, -- show open fold icons
        git_hl = true, -- use Git Signs hl for fold icons
      },
      git = {
        -- patterns to match Git signs
        patterns = { "GitSign", },
      },
      refresh = 50, -- refresh at most every 50ms
    },
    quickfile = {},
    styles = {
      notification_history = {
        keys = {
          q = "close",
          { "<esc>", "close", mode = "n" },
        },
      },
    }
  })
end)
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

later(function()
  map("n", "<leader>gi", function() Snacks.picker.gh_issue() end, {desc = "GitHub Issues (open)" })
  map("n", "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, {desc = "GitHub Issues (all)" })
  map("n", "<leader>gp", function() Snacks.picker.gh_pr() end, {desc = "GitHub Pull Requests (open)" })
  map("n", "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, {desc = "GitHub Pull Requests (all)" })

  -- thanks to https://www.reddit.com/r/neovim/comments/1j55o9c/comment/mgny6eo/
  Snacks.toggle.option("spell", { name = "󰓆 Spell Checking" }):map("<leader>us")
  Snacks.toggle.option("wrap", { name = "󰖶 Wrap Long Lines" }):map("<leader>uw")
  Snacks.toggle.option("list", { name = "󱁐 List (Visible Whitespace)" }):map("<leader>ul")
  Snacks.toggle.diagnostics({ name = " Diagnostics" }):map("<leader>uD") -- TODO: test this
  Snacks.toggle.indent({ name = "Indent" }):map("<leader>ui")
  Snacks.toggle
    .new({
      id = "git_blame",
      name = " Git Blame",
      get = function()
        return require("gitsigns.config").config.current_line_blame
        -- return true
      end,
      set = function(state)
        require("gitsigns").toggle_current_line_blame(state)
      end,
    })
    :map("<leader>ub")
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
    :map("<leader>uh") -- TODO: test this
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
    :map("<leader>uH") -- TODO: test this
  Snacks.toggle
    .new({
      id = "transparency",
      name = "Transparency",
      get = function() return g.transparent_enabled end,
      set = function() require("transparent").toggle() end,
    })
    :map("<leader>ut") -- transparency!

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
  map("n", "<leader>e", function() require("snacks").explorer({
    -- <C-q> shouldn't open qflist
    win = {
      list = {
        keys = {
          ["<C-q>"] = { "close", mode = { "i", "n" } },
        }
      }
    }
  }) end, { desc = "Toggle Explorer" })
  map("n", "<leader>gs", Snacks.picker.git_status, { desc = "Git Status" })
  map("n", "<leader>gl", Snacks.picker.git_log_file, { desc = "Git Log this file" })
  map("n", "<leader>gj", Snacks.picker.git_log_line, { desc = "Git Log this line" })
  map("n", "<leader>gL", Snacks.picker.git_log, { desc = "Git Log" })
end)

-- git integration
later(function()
  local gitsigns = require('gitsigns')
  gitsigns.setup({ current_line_blame = true })
  map("n", "<leader>gb", gitsigns.blame, {desc = "View Git Blame"})
  map("n", "<leader>gd", gitsigns.diffthis, {desc = "View Git Diff"})
end)



-- which-key for showing mappings
later(function()
  local wk = require("which-key")
  wk.setup({
    -- mini.surround maps bare `s` to <Nop>, which which-key's
    -- auto-trigger skips (single-letter keys aren't auto-safe)
    triggers = {
      { "<auto>", mode = "nxso" },
      { "s", mode = { "n", "x" } },
    },
    spec = {
      { "<leader>f", group = "find" }, -- group
      { "<leader>g", group = "git" }, -- group
      { "<leader>t", group = "terminal" }, -- group
      { "<esc><esc>", hidden = true}, -- hide popup for <esc><esc> -> :noh
      {
        mode = { "n", "v" },
        { "s", group = "Surrounding"  },
      }
    }
  })
end)

-- toggleterm
later(function()
  require("toggleterm").setup({
    direction = "float"
  })
  map("n", "<leader>tr", ":ToggleTerm direction=vertical<cr>", { desc = "right" })
  map("n", "<leader>tb", ":ToggleTerm direction=horizontal<cr>", { desc = "below" })
  map("n", "<leader>tf", ":ToggleTerm direction=float<cr>", { desc = "floating" })
  map("n", "<leader>tt", ":ToggleTerm direction=float<cr>", { desc = "floating" })
end)
later(function()
  local Terminal  = require('toggleterm.terminal').Terminal
  local btop = Terminal:new({ cmd = "btop", hidden = true })
  map("n", "<leader>tp", function() btop:toggle() end, { desc = "`btop`" })
  local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })
  map("n", "<leader>gg", function() lazygit:toggle() end, { desc = "`lazygit`" })
end)

-- mini!
local miniicons = require("mini.icons")
now(function() miniicons.setup() end)
later(miniicons.mock_nvim_web_devicons)
later(function() require('mini.surround').setup() end)
later(function() require('mini.splitjoin').setup() end)
later(function()
  local gen_loader = require('mini.snippets').gen_loader
  local snippets = require("mini.snippets")
  snippets.setup({
    snippets = {
      -- load custom file with global snippets first (adjust for windows)
      gen_loader.from_file('~/.config/nvim/snippets/global.json'),

      -- load snippets based on current language by reading files from
      -- "snippets/" subdirectories from 'runtimepath' directories.
      gen_loader.from_lang(),
    },
    mappings = {
      jump_next = "<tab>",
      jump_prev = "<s-tab>",
    }
  })
  snippets.start_lsp_server()
end)
later(function() require("mini.pairs").setup() end)
later(function()
  require("mini.move").setup({
    mappings = {
      -- Move visual selection in Visual mode.
      left = '<M-Left>',
      right = '<M-Right>',
      down = '<M-Down>',
      up = '<M-Up>',
      -- Move current line in Normal mode
      line_left = '<M-Left>',
      line_right = '<M-Right>',
      line_down = '<M-Down>',
      line_up = '<M-Up>',
    }
  })
end)
later(function()
  require("mini.completion").setup({
    delay = { completion = 50 },
    lsp_completion = {
      source_func = "omnifunc", -- enables snippets to be completed
    },
  })
  -- disable completion for inputs!
  local f = function(args) vim.b[args.buf].minicompletion_disable = true end
  vim.api.nvim_create_autocmd('FileType', { pattern = {'snacks_input', 'snacks_picker_input'}, callback = f })
end)

later(function() require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
  },
  -- combine snacks.notifier + noice notify!
  notify = {},
  -- you can enable a preset for easier configuration
  presets = {
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
}) end)

-- todo-comments
later(function() require("todo-comments").setup() end)

-- guess-indent
now(function() require("guess-indent").setup() end)

-- configure LSPs

--
---


--- misc keybinds
map("n", "<C-q>", ":q<cr>", {desc = "Quit"})
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
later(function()
  vim.keymap.del({ 'i', 's' }, '<Tab>')
  vim.keymap.del({ 'i', 's' }, '<S-Tab>')
end)
