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
  vim.g.nvim_tree_group_empty = 0
  vim.g.nvim_tree_git_hl = 0
  vim.g.nvim_tree_width_allow_resize = 1
  vim.g.nvim_tree_root_folder_modifier = ':t'
  vim.g.nvim_tree_highlight_opened_files = 0

  local P = fss.style.palette
  require('fss.highlights').plugin(
    'NvimTree',
    { 'NvimTreeIndentMarker', { link = 'Comment' } },
    { 'NvimTreeNormal', { link = 'Normal' } },
    { 'NvimTreeNormalNC', { link = 'Normal' } },
    { 'NvimTreeSignColumn', { link = 'Normal' } },
    { 'NvimTreeEndOfBuffer', { link = 'Normal' } },
    { 'NvimTreeVertSplit', { link = 'PanelVertSplit' } },
    { 'NvimTreeStatusLine', { link = 'PanelSt' } },
    { 'NvimTreeStatusLineNC', { link = 'PanelStNC' } },
    {
      'NvimTreeRootFolder',
      { bold = true, italic = true, foreground = P.magenta },
    }
  )

  fss.nnoremap('<c-n>', [[<cmd>NvimTreeToggle<CR>]])
  -- fss.nnoremap('-', toggle_replace)

  local winopts = require('nvim-tree.view').View.winopts
  winopts.winfixwidth = false
  winopts.winfixheight = false

  require('which-key').register {
    ['-'] = {
      function()
        local previous_buf = vim.api.nvim_get_current_buf()
        require('nvim-tree').open_replacing_current_buffer()
        require('nvim-tree').find_file(false, previous_buf)
      end,
      'NvimTree in place',
    },
  }

  require('nvim-tree').setup {
    update_cwd = false,
    git = {
      enable = false,
      timeout = 100,
    },
    view = {
      number = true,
      relativenumber = true,
      mappings = {
        list = {
          -- NOTE: default to editing the file in place, netrw-style
          { key = 'cd', cb = action 'cd' },
          {
            key = { '<C-e>', 'o', '<CR>' },
            action = 'edit_in_place',
          },
          -- NOTE: override the "split" to avoid treating nvim-tree
          -- window as special. Splits will appear as if nvim-tree was a
          -- regular window
          {
            key = '<C-v>',
            action = 'split_right',
            action_cb = function(node)
              vim.cmd('vsplit ' .. vim.fn.fnameescape(node.absolute_path))
            end,
          },
          {
            key = '<C-x>',
            action = 'split_bottom',
            action_cb = function(node)
              vim.cmd('split ' .. vim.fn.fnameescape(node.absolute_path))
            end,
          },
          -- NOTE: override the "open in new tab" mapping to fix the error
          -- that occurs there
          {
            key = '<C-t>',
            action = 'new_tab',
            action_cb = function(node)
              vim.cmd('tabnew ' .. vim.fn.fnameescape(node.absolute_path))
            end,
          },
        },
      },
    },
    actions = {
      change_dir = {
        -- NOTE: netrw-style, do not change the cwd when navigating
        enable = false,
      },
    },
    diagnostics = {
      enable = true,
    },
    system_open = {
      cmd = 'open',
    },
    hijack_netrw = true,
    filters = {
      custom = { '.DS_Store', 'fugitive:', '.git' },
    },
  }
end
