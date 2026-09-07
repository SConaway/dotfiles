local util = require "config.util"

return {
  src = util.gh "folke/todo-comments.nvim", -- highlight TODO, etc. in comment
  defer = true,
  config = function() require("todo-comments").setup() end,
}
