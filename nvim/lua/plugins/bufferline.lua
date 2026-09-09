local util = require "config.util"

return {
  src = {
    util.gh "akinsho/bufferline.nvim",
  },
  config = function()
    require("bufferline").setup {
      options = {
        -- catppuccin ships its own BufferLine* highlights; without this,
        -- bufferline's own highlights (below) set `default = true` and
        -- silently lose to catppuccin's, since that colorscheme loads first
        themable = false,
      },
      highlights = {
        -- *_selected,*_visible  are left as defaults so the selected tab still has its bg
        background = { bg = "none" },
        fill = { bg = "none" },
        -- buffer_selected  = { bg = "none", fg = "#fab387" },
        -- buffer_visible  = { bg = "none", fg = "#a6adc8" },
        close_button = { bg = "none" },
        -- close_button_selected  = { bg = "none" },
        -- close_button_visible  = { bg = "none" },
        duplicate = { bg = "none" },
        -- duplicate_selected  = { bg = "none" },
        -- duplicate_visible  = { bg = "none" },
        error = { bg = "none" },
        -- error_selected  = { bg = "none" },
        -- error_visible  = { bg = "none" },
        hint = { bg = "none" },
        -- hint_selected  = { bg = "none" },
        -- hint_visible  = { bg = "none" },
        -- indicator_selected  = { bg = "none" },
        -- indicator_visible  = { bg = "none" },
        info = { bg = "none" },
        -- info_selected  = { bg = "none" },
        -- info_visible  = { bg = "none" },
        modified = { bg = "none" },
        -- modified_selected  = { bg = "none" },
        -- modified_visible  = { bg = "none" },
        numbers = { bg = "none" },
        -- numbers_selected  = { bg = "none" },
        -- numbers_visible  = { bg = "none" },
        offset_separator = { bg = "none" },
        pick = { bg = "none" },
        -- pick_selected  = { bg = "none" },
        -- pick_visible  = { bg = "none" },
        separator = { bg = "none" },
        -- separator_selected  = { bg = "none" },
        -- separator_visible  = { bg = "none" },
        tab = { bg = "none" },
        tab_close = { bg = "none" },
        -- tab_selected  = { bg = "none" },
        tab_separator = { bg = "none" },
        -- tab_separator_selected  = { bg = "none" },
      },
    }
  end,
}
