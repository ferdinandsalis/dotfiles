return function()
  local action = require('nvim-tree.config').nvim_tree_callback

  vim.g.nvim_tree_icons = {
    default = '',
    git = {
      unstaged = '',
      staged = '',
      unmerged = '',
      renamed = '',
      untracked = '',
      deleted = '',
    },
  }

  vim.g.nvim_tree_special_files = {}
  vim.g.nvim_tree_indent_markers = 1
  vim.g.nvim_tree_group_empty = 1
  vim.g.nvim_tree_git_hl = 0
  vim.g.nvim_tree_width_allow_resize = 1
  vim.g.nvim_tree_root_folder_modifier = ':t'
  vim.g.nvim_tree_highlight_opened_files = 1

  fss.nnoremap('<c-n>', [[<cmd>NvimTreeToggle<CR>]])

  require('nvim-tree').setup {
    git = {
      enable = true,
      timeout = 200,
    },
    view = {
      width = 38,
      auto_resize = true,
      list = {
        { key = 'cd', cb = action 'cd' },
      },
    },
    diagnostics = {
      enable = true,
    },
    hijack_directories = {
      enable = true,
      auto_open = true,
    },
    system_open = {
      cmd = 'open',
    },
    sort_by = 'modification_time',
    disable_netrw = false,
    hijack_netrw = true,
    open_on_setup = false,
    hijack_cursor = false,
    update_cwd = true,
    update_focused_file = {
      enable = true,
      update_cwd = false,
    },
    filters = {
      custom = { '.DS_Store', 'fugitive:', '.git' },
    },
  }
end
