local util = require "config.util"

return {
  src = util.gh "nmac427/guess-indent.nvim", -- guess-indent to auto configure the indentation settings
  config = function() require("guess-indent").setup {} end,
}
