local util = require "config.util"

return {
  src = util.gh "folke/snacks.nvim", -- snacks: search pickers, file explorer, indent guides, notifications part 1, UI toggles, statuscolumn additions
  config = function()
    require("snacks").setup {
      explorer = {},
      picker = {
        layouts = {
          sidebar = {
            layout = {
              width = 30,
              min_width = 20,
            },
          },
        },
        win = {
          input = {
            keys = {
              ["<Esc>"] = { "close", mode = { "n", "i" } },
              -- <C-q> shouldn't open qflist
              ["<C-q>"] = { "close", mode = { "i", "n" } },
            },
          },
        },
      },
      indent = {
        animate = {
          enabled = false,
        },
      },
      -- lazygit = {}, -- skip this as it doesn't keep the same styles
      notifier = {}, -- combine with snacks notifier too
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
          patterns = { "GitSign" },
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
      },
    }

    -- https://github.com/folke/snacks.nvim/blob/main/docs/keymap.md
    local map = Snacks.keymap.set
    -- stolen from snacks' docs
    _G.dd = function(...) Snacks.debug.inspect(...) end
    _G.bt = function() Snacks.debug.backtrace() end
    vim._print = function(_, ...) dd(...) end

    map("n", "<leader>gi", function() Snacks.picker.gh_issue() end, { desc = "GitHub Issues (open)" })
    map("n", "<leader>gI", function() Snacks.picker.gh_issue { state = "all" } end, { desc = "GitHub Issues (all)" })
    map("n", "<leader>gp", function() Snacks.picker.gh_pr() end, { desc = "GitHub Pull Requests (open)" })
    map(
      "n",
      "<leader>gP",
      function() Snacks.picker.gh_pr { state = "all" } end,
      { desc = "GitHub Pull Requests (all)" }
    )

    -- thanks to https://www.reddit.com/r/neovim/comments/1j55o9c/comment/mgny6eo/
    Snacks.toggle.option("spell", { name = "󰓆 Spell Checking" }):map "<leader>us"
    Snacks.toggle.option("wrap", { name = "󰖶 Wrap Long Lines" }):map "<leader>uw"
    Snacks.toggle.option("list", { name = "󱁐 List (Visible Whitespace)" }):map "<leader>ul"
    Snacks.toggle.diagnostics({ name = "Diagnostics" }):map "<leader>uD"
    Snacks.toggle.indent():map "<leader>ui"
    Snacks.toggle
      .new({
        id = "git_blame",
        name = "Git Blame",
        get = function() return require("gitsigns.config").config.current_line_blame end,
        set = function(state) require("gitsigns").toggle_current_line_blame(state) end,
      })
      :map "<leader>ub"
    Snacks.toggle
      .new({
        id = "git_sign_column",
        name = "Git Sign Column",
        get = function() return require("gitsigns.config").config.signcolumn end,
        set = function(state) require("gitsigns").toggle_signs(state) end,
      })
      :map "<leader>ug"
    Snacks.toggle
      .new({
        id = "number",
        name = "Line Numbers",
        get = function() return vim.wo.number end,
        set = function(state) vim.wo.number = state end,
      })
      :map "<leader>un"
    Snacks.toggle
      .new({
        id = "relativenumber",
        name = "Relative Line Numbers",
        get = function() return vim.wo.relativenumber end,
        set = function(state)
          -- if no nums shown, enable them too
          if vim.wo.number == false then vim.wo.number = true end
          vim.wo.relativenumber = state
        end,
      })
      :map "<leader>uN"
    Snacks.toggle
      .new({
        id = "format_on_save",
        name = "󰊄 Format on Save (global)",
        get = function() return not vim.g.disable_autoformat end,
        set = function(state) vim.g.disable_autoformat = not state end,
      })
      :map "<leader>uf"
    Snacks.toggle
      .new({
        id = "format_on_save_buffer",
        name = "󰊄 Format on Save (buffer)",
        get = function() return not vim.b.disable_autoformat end,
        set = function(state) vim.b.disable_autoformat = not state end,
      })
      :map "<leader>uF"
    Snacks.toggle
      .new({
        id = "inline_hints",
        name = "LSP Inline Hints",
        get = vim.lsp.inlay_hint.is_enabled,
        set = function(state) vim.lsp.inlay_hint.enable(state) end,
      })
      :map "<leader>uh"
    Snacks.toggle
      .new({
        id = "inline_hints_end",
        name = "LSP Inline Hints at Line End",
        get = function() return vim.g.snacks_toggle_lsp_hints_end end,
        set = function(state)
          require("lsp-endhints").toggle()
          vim.g.snacks_toggle_lsp_hints_end = state
        end,
      })
      :map "<leader>uH"
    Snacks.toggle
      .new({
        id = "transparency",
        name = "Transparency",
        get = function() return vim.g.transparent_enabled end,
        set = function() require("transparent").toggle() end,
      })
      :map "<leader>ut" -- transparency!
    Snacks.toggle
      .new({
        id = "rendermarkdown",
        name = "Render Markdown",
        get = function() return require("render-markdown").get() end,
        set = function() require("render-markdown").toggle() end,
      })
      :map "<leader>um" -- markdown preview!
    Snacks.toggle
      .new({
        id = "pairs",
        name = "Autopairs",
        get = function() return not require("nvim-autopairs").state.disabled end,
        set = function(state)
          if state then
            require("nvim-autopairs").enable()
          else
            require("nvim-autopairs").disable()
          end
        end,
      })
      :map "<leader>up"

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
    map("n", "<leader>e", function()
      require("snacks").explorer {
        -- <C-q> shouldn't open qflist
        win = {
          list = {
            keys = {
              ["<C-q>"] = { "close", mode = { "i", "n" } },
            },
          },
        },
      }
    end, { desc = "Toggle Explorer" })
    map("n", "<leader>gs", Snacks.picker.git_status, { desc = "Git Status" })
    map("n", "<leader>gl", Snacks.picker.git_log_file, { desc = "Git Log this file" })
    map("n", "<leader>gj", Snacks.picker.git_log_line, { desc = "Git Log this line" })
    map("n", "<leader>gL", Snacks.picker.git_log, { desc = "Git Log" })
  end,
}
