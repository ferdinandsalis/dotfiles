return function()
  local icons = fss.style.icons
  local highlights = require('fss.highlights')

  highlights.plugin('NeoTree', {
    NeoTreeIndentMarker = { link = 'Comment' },
    NeoTreeNormal = { link = 'PanelBackground' },
    NeoTreeNormalNC = { link = 'PanelBackground' },
    NeoTreeRootName = { bold = true, italic = true },
    NeoTreeCursorLine = { link = 'Visual' },
    NeoTreeStatusLine = { link = 'PanelSt' },
    NeoTreeTabBackground = { link = 'PanelBackground' },
    NeoTreeTab = {
      bg = { from = 'PanelBackground' },
      fg = { from = 'Comment' },
    },
    NeoTreeSeparator = { link = 'PanelBackground' },
    NeoTreeActiveTab = {
      bg = { from = 'PanelBackground' },
      fg = 'fg',
      bold = true,
    },
  })

  vim.g.neo_tree_remove_legacy_commands = 1

  fss.nnoremap('<c-n>', '<Cmd>Neotree toggle reveal<CR>')
  fss.nnoremap('-', '<Cmd>Neotree current %:p:h:h %:p<CR>')

  require('neo-tree').setup({
    reveal = true,
    source_selector = {
      winbar = true, -- toggle to show selector on winbar
      statusline = false, -- toggle to show selector on statusline
      tabs_layout = 'start',
      tab_labels = { -- falls back to source_name if nil
        filesystem = ' Files',
        buffers = ' Buffers',
        git_status = ' Git',
      },
      tabs_min_width = 11,
      separator = ' ',
      highlight_tab = 'NeoTreeTab',
      highlight_tab_active = 'NeoTreeActiveTab',
      highlight_separator = 'NeoTreeSeparator',
      highlight_separator_active = 'NeoTreeSeparator',
      highlight_background = 'NeoTreeTabBackground',
    },
    enable_git_status = true,
    git_status_async = true,
    event_handlers = {
      -- {
      --   event = 'neo_tree_buffer_enter',
      --   handler = function()
      --     highlights.set_hl('Cursor', { blend = 100 })
      --   end,
      -- },
      -- {
      --   event = 'neo_tree_buffer_leave',
      --   handler = function()
      --     highlights.set_hl('Cursor', { blend = 0 })
      --     -- require('neo-tree').close_all()
      --   end,
      -- },
      {
        event = 'file_opened',
        handler = function()
          require('neo-tree').close_all()
        end,
      },
    },
    use_popups_for_input = false,
    filesystem = {
      use_libuv_file_watcher = true,
      hijack_netrw_behavior = 'open_current',
      follow_current_file = false,
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
      mapping_options = {
        noremap = true,
        nowait = true,
      },
      width = 40,
      mappings = {
        ['o'] = 'toggle_node',
        ['-'] = 'navigate_up',
        ['<bs>'] = 'close_node',
        ['<c-s>'] = 'open_split',
        ['<c-v>'] = 'open_vsplit',
      },
    },
  })
end
