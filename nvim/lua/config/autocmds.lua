-- tame auto-comment (`formatoptions`)
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("tame-formatoptions", { clear = true }),
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove { "r" }
    -- o = auto-comment on `o`/`O` in normal mode
    -- r = auto-comment on <Enter> in insert mode
  end,
})

-- hot-reload core config (init.lua, lua/config/*.lua) on save: clears the
-- module cache and re-requires everything, including plugins. Narrower,
-- per-file hot-reload for lua/plugins/*.lua lives in plugins/init.lua.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("hot-reload-config", { clear = true }),
  pattern = {
    vim.env.MYVIMRC,
    vim.fn.stdpath "config" .. "/lua/config/*.lua",
  },
  callback = function()
    for name in pairs(package.loaded) do
      if name == "config" or name:match "^config%." or name == "plugins" or name:match "^plugins%." then
        package.loaded[name] = nil
      end
    end
    local ok, err = pcall(require, "config")
    if ok then
      vim.notify("config reloaded", vim.log.levels.INFO)
    else
      vim.notify("config reload failed: " .. tostring(err), vim.log.levels.ERROR)
    end
  end,
})
