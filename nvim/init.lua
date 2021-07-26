-- This is all taken from https://github.com/akinsho/dotfiles
-- with some minor modifications

-- NOTE: this is set by nvim by default but maybe too late
vim.cmd 'syntax enable'

vim.g.dotfiles = '~/.doffiles'
vim.g.vim_dir = '~/.dotfiles/nvim'

------------------------------------------------------------------------
-- Leader bindings
------------------------------------------------------------------------

vim.g.mapleader = ',' -- Remap leader key
vim.g.maplocalleader = ' ' -- Local leader is <Space>

require 'fss.globals'
require 'fss.settings'
require 'fss.highlights'
require 'fss.statusline'
require 'fss.plugins'
