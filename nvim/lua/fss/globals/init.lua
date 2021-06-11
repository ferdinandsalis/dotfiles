require("fss.globals.utils")

-----------------------------------------------------------------------------//
-- UI
-----------------------------------------------------------------------------//
-- Consistent store of various UI items to reuse throughout my config
fss.style = {
  icons = {
    error = "✗",
    warning = "",
    info = "",
    hint = ""
  },
  border = {
    curved = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}
  },
  palette = {
    white = "#c0caf5",
    dark_red = "#db4b4b",
    green = "#9ece6a",
    light_yellow = "#e0af68",
    dark_blue = "#3d59a1",
    magenta = "#bb9af7",
    comment_grey = "#565f89",
    whitesmoke = "#3b4261",
    bright_blue = "#7aa2f7"
  }
}

-----------------------------------------------------------------------------//
-- Messaging
-----------------------------------------------------------------------------//
if vim.notify then
  ---Override of vim.notify to open floating window
  --@param message of the notification to show to the user
  --@param log_level Optional log level
  --@param opts Dictionary with optional options (timeout, etc)
  vim.notify = function(message, log_level, _)
    assert(message, "The message key of vim.notify should be a string")
    fss.notify({message}, {timeout = 5000, log_level = log_level})
  end
end

-----------------------------------------------------------------------------//
-- Debugging
-----------------------------------------------------------------------------//
-- inspired/copied from @tjdevries
P = function(v)
  print(vim.inspect(v))
  return v
end

if pcall(require, "plenary") then
  RELOAD = require("plenary.reload").reload_module

  R = function(name)
    RELOAD(name)
    return require(name)
  end
end

-- inspect the contents of an object very quickly
-- in your code or from the command-line:
-- USAGE:
-- in lua: dump({1, 2, 3})
-- in commandline: :lua dump(vim.loop)
---@vararg any
function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, {...})
  print(unpack(objects))
end

function _G.plugin_loaded(plugin_name)
  local plugins = _G.packer_plugins or {}
  return plugins[plugin_name] and plugins[plugin_name].loaded
end
