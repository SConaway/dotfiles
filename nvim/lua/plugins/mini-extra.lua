-- the rest of mini.nvim's submodules (installed by plugins/mini.lua) that
-- don't need to be ready before the first keystroke.
return {
  defer = true,
  config = function()
    require("mini.icons").mock_nvim_web_devicons()

    require("mini.surround").setup()
    require("mini.splitjoin").setup()

    local snippets = require "mini.snippets"
    local gen_loader = snippets.gen_loader
    snippets.setup {
      snippets = {
        -- load custom file with global snippets first (adjust for windows)
        gen_loader.from_file "~/.config/nvim/snippets/global.json",

        -- load snippets based on current language by reading files from
        -- "snippets/" subdirectories from 'runtimepath' directories.
        gen_loader.from_lang(),
      },
      mappings = {
        jump_next = "<tab>",
        jump_prev = "<s-tab>",
      },
    }
    snippets.start_lsp_server()

    require("mini.pairs").setup()

    require("mini.move").setup {
      mappings = {
        -- Move visual selection in Visual mode.
        left = "<M-Left>",
        right = "<M-Right>",
        down = "<M-Down>",
        up = "<M-Up>",
        -- Move current line in Normal mode
        line_left = "<M-Left>",
        line_right = "<M-Right>",
        line_down = "<M-Down>",
        line_up = "<M-Up>",
      },
    }

    require("mini.completion").setup {
      delay = { completion = 50 },
      lsp_completion = {
        source_func = "omnifunc", -- enables snippets to be completed
      },
    }
    -- disable completion for inputs!
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "snacks_input", "snacks_picker_input" },
      callback = function(args) vim.b[args.buf].minicompletion_disable = true end,
    })

    -- autocomplete for cmdline
    require("mini.cmdline").setup {
      autopeek = {
        n_context = 5,
      },
    }
  end,
}
