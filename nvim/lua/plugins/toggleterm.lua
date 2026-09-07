local util = require "config.util"

return {
  src = util.gh "akinsho/toggleterm.nvim", -- terminal library
  defer = true,
  config = function()
    require("toggleterm").setup { direction = "float" }
    local map = Snacks.keymap.set
    map("n", "<leader>tr", ":ToggleTerm direction=vertical<cr>", { desc = "right" })
    map("n", "<leader>tb", ":ToggleTerm direction=horizontal<cr>", { desc = "below" })
    map("n", "<leader>tf", ":ToggleTerm direction=float<cr>", { desc = "floating" })
    map("n", "<leader>tt", ":ToggleTerm direction=float<cr>", { desc = "floating" })

    local Terminal = require("toggleterm.terminal").Terminal
    local btop = Terminal:new { cmd = "btop", hidden = true }
    map("n", "<leader>tp", function() btop:toggle() end, { desc = "`btop`" })
    local lazygit = Terminal:new { cmd = "lazygit", hidden = true }
    map("n", "<leader>gg", function() lazygit:toggle() end, { desc = "`lazygit`" })
  end,
}
