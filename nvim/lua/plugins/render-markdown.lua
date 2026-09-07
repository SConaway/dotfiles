local util = require "config.util"

return {
  src = util.gh "MeanderingProgrammer/render-markdown.nvim", -- markdown!
  defer = true,
  config = function()
    require("render-markdown").setup {
      enabled = false,
      completions = { lsp = { enabled = true } },
    }
  end,
}
