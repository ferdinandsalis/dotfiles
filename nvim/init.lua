------------------------------------------------------------------------
-- NVIM CONFIG
-- This is all shamefully taken from
-- http://github.com/akinsho/dotfiles
-- with some minor modifications
------------------------------------------------------------------------
vim.g.os = vim.loop.os_uname().sysname
vim.g.open_command = vim.g.os == 'Darwin' and 'open' or 'xdg-open'
vim.g.dotfiles = '~/.dotfiles'
vim.g.vim_dir = '~/.dotfiles/nvim'

------------------------------------------------------------------------
-- Leader bindings
------------------------------------------------------------------------
vim.g.mapleader = ',' -- Remap leader key
vim.g.maplocalleader = ' ' -- Local leader is <Space>

local ok, reload = pcall(require, 'plenary.reload')
RELOAD = ok and reload.reload_module or function(...)
  return ...
end
function R(name)
  RELOAD(name)
  return require(name)
end

-------------------------------------------------------------------------
-- Plugin Configurations
------------------------------------------------------------------------
R 'fss.globals'
R 'fss.styles'
R 'fss.settings'
R 'fss.highlights'
R 'fss.statusline'
R 'fss.plugins'
