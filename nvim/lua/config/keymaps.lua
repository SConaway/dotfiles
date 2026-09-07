-- misc, non-plugin-specific keybinds. Snacks is guaranteed loaded by the
-- time this file runs (see lua/config/init.lua), so `map` is safe to use.
local map = Snacks.keymap.set

map("n", "<C-q>", ":q<cr>", { desc = "Quit" })
map("n", "<leader>q", ":q<cr>", { desc = "Quit" })
map("n", "<leader>w", ":w<cr>", { desc = "Save" })
map("n", "<esc><esc>", ":noh<cr>", { desc = ":noh" })
map("n", "U", "<C-r>", { desc = "Redo" })
map("n", "<leader>/", "gcc", { desc = "comment", remap = true }) -- add remap as otherwise can't pass motions directly
map("v", "<leader>/", "gc", { desc = "comment", remap = true }) -- add remap as otherwise can't pass motions directly
map("n", "<leader>ch", ":checkhealth<cr>", { desc = "Check Health" })
map("n", "<leader>]", ":vsp<cr>", { desc = "Vertical split" })
map("n", "<leader>[", ":sp<cr>", { desc = "Horizontal split" })
map("n", "<leader>pc", function()
  -- filter from :h vim.pack-examples
  -- get all, filter by inactive, get name
  local packages = vim
    .iter(vim.pack.get())
    :filter(function(x) return not x.active end)
    :map(function(x) return x.spec.name end)
    :totable()
  -- TODO: confirm with user!
  vim.pack.del(packages)
end, { desc = "Clean Plugins" })
map("n", "<leader>pu", vim.pack.update, { desc = "Update Plugins" })
map("n", "<leader>pm", ":Mason<cr>", { desc = "Open Mason" })
map("n", "<leader>li", ":checkhealth vim.lsp<cr>", { desc = "LSP Info" })
