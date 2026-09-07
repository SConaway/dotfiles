local util = require "config.util"

return {
  src = util.gh "folke/which-key.nvim", -- keybinding help
  defer = true,
  config = function()
    require("which-key").setup {
      -- mini.surround maps bare `s` to <Nop>, which which-key's
      -- auto-trigger skips (single-letter keys aren't auto-safe)
      triggers = {
        { "<auto>", mode = "nxso" },
        { "s", mode = { "n", "x" } },
      },
      spec = {
        { "<leader>f", group = "find" }, -- group
        { "<leader>g", group = "git" }, -- group
        { "<leader>p", group = "plugins" }, -- group
        { "<leader>t", group = "terminal" }, -- group
        { "<esc><esc>", hidden = true }, -- hide popup for <esc><esc> -> :noh
        { "s", group = "Surrounding" },
      },
    }
  end,
}
