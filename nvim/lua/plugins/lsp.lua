local util = require "config.util"

return {
  src = {
    util.gh "neovim/nvim-lspconfig", -- adds many LSP configs
    util.gh "mason-org/mason.nvim", -- helps install LSPs/linters/formatters
    util.gh "mason-org/mason-lspconfig.nvim", -- mason pt. 2
    util.gh "WhoIsSethDaniel/mason-tool-installer.nvim", -- require installing formatters, etc.
    util.gh "folke/lazydev.nvim", -- enhances Lua LSP
    util.gh "chrisgrieser/nvim-lsp-endhints", -- move inlay hints to end of line
    util.gh "dchinmay2/clangd_extensions.nvim", -- clangd stuff!
    util.gh "stevearc/conform.nvim", -- format!
    util.gh "folke/trouble.nvim", -- diagnostics
  },
  defer = true,
  config = function()
    local function exists(p) return vim.fn.executable(p) == 1 end
    -- stolen from astrocommunity.pack.cpp:
    local uname = (vim.uv or vim.loop).os_uname()
    local is_linux_arm = uname.sysname == "Linux"
      and (uname.machine == "aarch64" or vim.startswith(uname.machine, "arm"))
    local servers = {
      "lua_ls",
      "basedpyright", -- pyright doesn't include inlay hint support
    }
    if not is_linux_arm then table.insert(servers, "clangd") end -- doesn't install on arm linux?
    local formatters = {
      "black",
      "stylua",
    }
    local tools = {
      "codelldb",
    }
    if exists "go" then table.insert(servers, "gopls") end
    if exists "nix" then table.insert(servers, "nil_ls") end

    require("mason").setup {
      pip = {
        upgrade_pip = true,
      },
    }
    require("mason-lspconfig").setup {
      ensure_installed = servers,
    }
    local mti = require "mason-tool-installer"
    local mti_tools = util.table_merge(formatters, tools) -- add other things here
    mti.setup {
      ensure_installed = mti_tools,
    }
    -- run_on_start runs on `VimEnter` and therefore isn't working here
    mti.run_on_start() -- same function, just me triggering it manually

    -- enhance Lua / `nvim` LSP
    require("lazydev").setup {}

    -- set up formatting!!
    require("conform").setup {
      -- Map of filetype to formatters
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        go = { "goimports", "gofmt" },
        python = { "isort", "black" },
        -- Use the "*" filetype to run formatters on all filetypes.
        -- ["*"] = { "codespell" },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        ["_"] = { "trim_whitespace" },
      },
      -- Set this to change the default values when calling conform.format()
      -- This will also affect the default values for format_on_save/format_after_save
      default_format_opts = {
        lsp_format = "fallback",
      },
      -- If this is set, Conform will run the formatter on save.
      -- It will pass the table to conform.format().
      -- This can also be a function that returns the table.
      format_on_save = function(bufnr)
        -- return nothing to skip
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
        return {
          lsp_format = "fallback",
          timeout_ms = 500,
        }
      end,
      -- Set the log level. Use `:ConformInfo` to see the location of the log file.
      log_level = vim.log.levels.ERROR,
      -- Conform will notify you when a formatter errors
      notify_on_error = true,
      -- Conform will notify you when no formatters are available for the buffer
      notify_no_formatters = true,
    }

    -- this is starting to annoy me!
    -- vim.lsp.codelens.enable(true)
    vim.lsp.linked_editing_range.enable(true)
    vim.lsp.inlay_hint.enable(true)

    require("lsp-endhints").setup {
      autoEnableHints = true,
    }
    vim.g.snacks_toggle_lsp_hints_end = true

    require("trouble").setup {}

    local map = Snacks.keymap.set
    map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
    map(
      "n",
      "<leader>xX",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      { desc = "Buffer Diagnostics (Trouble)" }
    )
    map("n", "grs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
    map(
      "n",
      "<leader>cl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      { desc = "LSP Definitions / references / ... (Trouble)" }
    )
    map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
    map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
    map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
    map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
    map("n", "gs", vim.lsp.buf.signature_help, { desc = "Open signature help" })
  end,
}
