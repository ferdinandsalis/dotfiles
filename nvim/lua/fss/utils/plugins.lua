---Plugin Utils
local M = {}

local fmt = string.format

---Require a plugin config
---@param name string
---@return any
function M.conf(name)
  return require(fmt('fss.plugins.%s', name))
end

return M
