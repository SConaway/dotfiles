local util = require "config.util"

return {
  src = util.gh "xiyaowong/transparent.nvim", -- transparency!!
  -- vim.g.transparent_enabled / vim.g.transparent_groups are set in
  -- config/options.lua, before this plugin loads
}
