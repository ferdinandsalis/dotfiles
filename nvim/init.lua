-- This is all taken from https://github.com/akinsho/dotfiles
-- with some minor modifications
-- NOTE: this is set by nvim by default but maybe too late
vim.cmd("syntax enable")

vim.api.nvim_exec(
  [[
  augroup vimrc -- Ensure all autocommands are cleared
  autocmd!
  augroup END
]],
  ""
)

local uname = vim.loop.os_uname()
if uname.sysname == "Darwin" then
  vim.g.open_command = "open"
  vim.g.system_name = "macOS"
  vim.g.is_mac = true
elseif uname.sysname == "Linux" then
  vim.g.open_command = "xdg-open"
  vim.g.system_name = "Linux"
  vim.g.is_linux = true
end

vim.g.dotfiles = "~/.doftfiles"
vim.g.vim_dir = "~/.dotfiles/nvim"

------------------------------------------------------------------------
-- Leader bindings
------------------------------------------------------------------------

vim.g.mapleader = "," -- Remap leader key
vim.g.maplocalleader = " " -- Local leader is <Space>

require("fss")
