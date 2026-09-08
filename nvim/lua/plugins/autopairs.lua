local util = require "config.util"

return {
  src = util.gh "windwp/nvim-autopairs",
  defer = true,
  config = function()
    require("nvim-autopairs").setup {
      check_ts = true,
    }
  end,
}
