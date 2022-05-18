return function()
  local P = fss.style.palette
  require('fss.highlights').plugin('NeoTree', {
    NeoTreeNormal = { link = 'PanelBackground' },
    NeoTreeNormalNC = { link = 'PanelBackground' },
    NeoTreeCursorLine = { link = 'Visual' },
    NeoTreeGitIgnored = { foreground = P.comment },
    NeoTreeGitUntracked = { foreground = P.yellow },
    NeoTreeGitModified = { foreground = P.blue1 },
    NeoTreeIndentMarker = { foreground = P.fg_gutter },
    NeoTreeRootName = { bold = true, italic = true, foreground = P.magenta },
  })
  vim.g.neo_tree_remove_legacy_commands = 1
  local icons = fss.style.icons
  fss.nnoremap('<c-n>', '<Cmd>Neotree toggle reveal<CR>')
  fss.nnoremap('-', '<Cmd>Neotree current %:p:h:h %:p<CR>')

  require('neo-tree').setup({
    enable_git_status = true,
    git_status_async = true,
    event_handlers = {
      {
        event = 'neo_tree_buffer_enter',
        handler = function()
          vim.cmd('setlocal signcolumn=no')
          vim.cmd('highlight! Cursor blend=100')
        end,
      },
      {
        event = 'neo_tree_buffer_leave',
        handler = function()
          vim.cmd('highlight! Cursor blend=0')
        end,
      },
    },
    use_popups_for_input = false,
    filesystem = {
      use_libuv_file_watcher = true,
      group_empty_dirs = true,
      follow_current_file = true,
      hijack_netrw_behavior = 'open_current',
      find_command = 'fd',
      find_args = {
        fd = {
          '--exclude',
          '.git',
        },
      },
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = true,
      },
    },
    default_component_configs = {
      indent = {
        indent_size = 2,
        indent_marker = '┊', --"│",
        with_markers = true,
        with_arrows = true,
        padding = 0,
      },
      git_status = {
        symbols = {
          added = icons.git.add,
          deleted = icons.git.remove,
          modified = icons.git.mod,
          renamed = icons.git.rename,
          untracked = '',
          ignored = '',
          unstaged = '',
          staged = '',
          conflict = '',
        },
      },
    },
    window = {
      width = 40,
      mappings = {
        ['o'] = 'toggle_node',
        ['-'] = 'navigate_up',
        ['<bs>'] = 'close_node',
        -- ['<CR>'] = 'open_with_window_picker',
        ['<c-s>'] = 'split_with_window_picker',
        ['<c-v>'] = 'vsplit_with_window_picker',
      },
    },
  })
end
