local util = require "config.util"

return {
  src = util.gh "Bekaboo/dropbar.nvim",
  defer = false,
  -- -- this was in-progress work to try to let <q> *always* go one level up but
  -- -- i decided to see if that's something I need / want first.
  -- config = function()
  --   local function quit_back()
  --     local utils = require "dropbar.utils"
  --     local menu = utils.menu.get_current()
  --     if not menu then return end
  --
  --     dd(menu)
  --     menu.close(true)
  --   end
  --
  --   require("dropbar").setup {
  --     opts = {
  --       menu = {
  --         keymaps = {
  --           ["q"] = quit_back,
  --           ["<Esc>"] = quit_back,
  --         },
  --       },
  --     },
  --   }
  -- end,
}
