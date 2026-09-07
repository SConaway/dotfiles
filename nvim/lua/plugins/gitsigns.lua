local util = require "config.util"

return {
  src = util.gh "lewis6991/gitsigns.nvim", -- git integration
  defer = true,
  config = function()
    local gitsigns = require "gitsigns"
    gitsigns.setup { current_line_blame = true }
    local map = Snacks.keymap.set
    map("n", "<leader>gb", gitsigns.blame, { desc = "View Git Blame" })
    map("n", "<leader>gd", gitsigns.diffthis, { desc = "View Git Diff" })
  end,
}
