local util = require "config.util"

return {
  src = util.gh "brenoprata10/nvim-highlight-colors",
  defer = true,
  config = function()
    -- #123456
    -- rgb(100, 200, 255)
    -- bg-blue-400
    require("nvim-highlight-colors").setup {
      enable_tailwind = true,
      render = "virtual",
      virtual_symbol_position = "eol",
      virtual_symbox_suffix = "",
    }
  end,
}
