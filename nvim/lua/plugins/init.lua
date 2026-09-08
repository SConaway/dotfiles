-- explicit load order: plugins that expose globals/helpers other plugins
-- lean on (`Snacks`, mini's icons/statusline, etc.) go first. Everything
-- installs via one `vim.pack.add` call, then each plugin's `config()` runs
-- in this order -- immediately, unless the module sets `defer = true`, in
-- which case it's pushed past startup with `vim.schedule` (see below).
-- Only plugins something else depends on synchronously (Snacks/mini's
-- globals) or that must see the very first buffer nvim opens with
-- (guess-indent) stay un-deferred.
local order = {
  "transparent",
  "snacks",
  "gitsigns",
  "which-key",
  "toggleterm",
  "mini",
  "mini-extra",
  "todo-comments",
  "guess-indent",
  "autopairs",
  "noice",
  "render-markdown",
  "lsp",
}
if not require("config.util").is_work then table.insert(order, "wakatime") end

local specs, mods = {}, {}
for _, name in ipairs(order) do
  local mod = require("plugins." .. name)
  mods[name] = mod
  if type(mod.src) == "table" then
    vim.list_extend(specs, mod.src)
  elseif mod.src then
    table.insert(specs, mod.src)
  end
end

vim.pack.add(specs)

for _, name in ipairs(order) do
  local mod = mods[name]
  if mod.config then
    local function run()
      local ok, err = pcall(mod.config)
      if not ok then vim.notify(("plugins.%s: %s"):format(name, err), vim.log.levels.ERROR) end
    end
    if mod.defer then
      vim.schedule(run)
    else
      run()
    end
  end
end

-- mini-extra's snippets setup binds <Tab>/<S-Tab> for jump_next/jump_prev
-- (deferred, above); this removes them again afterwards, same as the old
-- init.lua did in its very last later() block. Scheduled last so it runs
-- after that deferred setup, whichever tick it landed on.
vim.schedule(function()
  -- pcall: on config reload these may already be gone
  pcall(vim.keymap.del, { "i", "s" }, "<Tab>")
  pcall(vim.keymap.del, { "i", "s" }, "<S-Tab>")
end)

-- hot-reload: re-run a single plugin file's config() on save, no restart
-- needed. Doesn't install a brand-new `src` beyond a quick vim.pack.add
-- check -- for a genuinely new plugin, restart nvim once.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("hot-reload-plugins", { clear = true }),
  pattern = vim.fn.stdpath "config" .. "/lua/plugins/*.lua",
  callback = function(args)
    local name = vim.fn.fnamemodify(args.file, ":t:r")
    if name == "init" then return end
    package.loaded["plugins." .. name] = nil
    local ok, mod = pcall(require, "plugins." .. name)
    if not ok then
      vim.notify("plugins." .. name .. ": " .. mod, vim.log.levels.ERROR)
      return
    end
    if not mod.config then return end
    local cok, err = pcall(mod.config)
    if cok then
      vim.notify("plugins." .. name .. " reloaded", vim.log.levels.INFO)
    else
      vim.notify("plugins." .. name .. ": " .. tostring(err), vim.log.levels.ERROR)
    end
  end,
})
