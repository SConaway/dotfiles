local M = {}

M.is_work = os.getenv "USER" == "stevenc"

--- shorthand for a github-hosted `vim.pack` source
function M.gh(repo) return "https://github.com/" .. repo end

--- https://www.reddit.com/r/lua/comments/rtiedd/comment/o9d8xlb
function M.table_merge(...)
  local result = {}
  for _, t in ipairs { ... } do
    for _, v in ipairs(t) do
      table.insert(result, v)
    end
  end
  return result
end

return M
