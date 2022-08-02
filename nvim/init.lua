----------------------------------------------------------------------------------------------------
-- NVIM CONFIG
-- This is all shamefully taken from
-- http://github.com/akinsho/dotfiles
-- with some minor modifications
----------------------------------------------------------------------------------------------------
vim.g.os = vim.loop.os_uname().sysname
vim.g.open_command = vim.g.os == 'Darwin' and 'open' or 'xdg-open'
vim.g.dotfiles = '~/.dotfiles'
vim.g.vim_dir = '~/.dotfiles/nvim'

-- Stop loading built in plugins
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.logipat = 1
vim.g.loaded_gzip = 1

-- Ensure all autocommands are cleared
vim.api.nvim_create_augroup('vimrc', {})

-- Leader bindings
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

-- Global namespace
_G.fss = fss
  or {
    mappings = {},
    ui = {
      winbar = { enable = false },
    },
  }

-- Plugin Configurations
R('fss.globals')
R('fss.styles')
R('fss.settings')
R('fss.highlights')
R('fss.plugins')
