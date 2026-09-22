local util = require "config.util"

return {
  src = util.gh "RRethy/vim-illuminate",
  defer = true,
  config = function()
    require("illuminate").configure {
      should_enable = function() return not vim.g.disable_illuminate end,
    }
  end,
}
