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

-- NOTE: A value of 0 for this variable disables filetype.vim. A value of 1 disables both filetype.vim
-- and filetype.lua (which you probably don’t want).
vim.g.did_load_filetypes = 0
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
