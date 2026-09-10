local util = require "config.util"

-- put this here, rather than in `config()`, so that `vim.pack.add()` doesn't
-- then run `.setup()` with the defaults
vim.g.render_markdown_config = {
  enabled = false,
  completions = { lsp = { enabled = true } },
}

return {
  src = util.gh "MeanderingProgrammer/render-markdown.nvim", -- markdown!
  defer = true,
}
