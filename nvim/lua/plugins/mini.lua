local util = require "config.util"

return {
  src = util.gh "nvim-mini/mini.nvim", -- mini.nvim: session resume, icons, surround, split/join, snippets, completion, move shortcuts, cmdline completion
  config = function()
    require("mini.misc").setup_restore_cursor()

    local miniicons = require "mini.icons"
    miniicons.setup()

    require("mini.tabline").setup()
    require("mini.git").setup()
    require("mini.diff").setup()

    -- https://nvim-mini.org/mini.nvim/doc/mini-statusline.html#ministatusline-example-content-defaultcontent
    -- much of this is stolen from `mini.nvim/lua/mini/statusline.lua` itself
    local function statusline()
      local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
      local git = MiniStatusline.section_git { trunc_width = 40 }
      local diff = MiniStatusline.section_diff { trunc_width = 75 }
      local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75 }
      local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
      -- local filename = MiniStatusline.section_filename { trunc_width = 140 }
      local fileinfo = function()
        local filetype = vim.bo.filetype

        local sizeBytes = math.max(vim.fn.line2byte(vim.fn.line "$" + 1) - 1, 0)
        local size = ""
        if sizeBytes < 1024 then
          size = string.format("%dB", sizeBytes)
        elseif sizeBytes < 1048576 then
          size = string.format("%.2fKiB", sizeBytes / 1024)
        else
          size = string.format("%.2fMiB", sizeBytes / 1048576)
        end
        return string.format("%s%s %s", miniicons.get("filetype", filetype), filetype, size)
      end
      local search = function()
        if vim.v.hlsearch == 0 then return "" end
        -- `searchcount()` can return errors because it is evaluated very often in
        -- statusline. For example, when typing `/` followed by `\(`, it gives E54.
        local ok, s_count = pcall(vim.fn.searchcount, { recompute = true })
        if not ok or s_count.current == nil or s_count.total == 0 then return "" end

        if s_count.incomplete == 1 then return "?/?" end

        local too_many = ">" .. s_count.maxcount
        local current = s_count.current > s_count.maxcount and too_many or s_count.current
        local total = s_count.total > s_count.maxcount and too_many or s_count.total
        return "  " .. current .. "/" .. total
      end
      return MiniStatusline.combine_groups {
        { hl = mode_hl, strings = { mode } },
        {
          hl = "MiniStatuslineDevinfo",
          strings = {
            git,
            " ",
            diff,
            " ",
            diagnostics,
            " ",
            lsp,
          },
        },
        "%<", -- Mark general truncate point
        "%=", -- center!
        -- { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=", -- center!
        { hl = "MiniStatuslineFileinfo", strings = { fileinfo() } },
        search(),
        " ",
        {
          hl = mode_hl,
          strings = {
            -- location
            "%l/%v",
          },
        },
      }
    end
    require("mini.statusline").setup {
      content = {
        active = statusline,
        inactive = statusline,
      },
    }
  end,
}
