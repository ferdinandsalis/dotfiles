return function()
  local icons = fss.style.icons
  local highlights = require('fss.highlights')

  local panel_dark_bg = highlights.get('PanelDarkBackground', 'bg')
  local tab_bg = highlights.alter_color(panel_dark_bg, 15)

  highlights.plugin('NeoTree', {
    { NeoTreeIndentMarker = { link = 'Comment' } },
    { NeoTreeNormal = { link = 'PanelBackground' } },
    { NeoTreeNormalNC = { link = 'PanelBackground' } },
    { NeoTreeRootName = { underline = true } },
    { NeoTreeCursorLine = { link = 'Visual' } },
    { NeoTreeStatusLine = { link = 'PanelSt' } },
    { NeoTreeTabActive = { bg = { from = 'PanelBackground' }, bold = true } },
    { NeoTreeTabInactive = { bg = tab_bg, fg = { from = 'Comment' } } },
    { NeoTreeTabSeparatorInactive = { bg = tab_bg, fg = panel_dark_bg } },
    {
      NeoTreeTabSeparatorActive = {
        inherit = 'PanelBackground',
        fg = { from = panel_dark_bg },
      },
    },
  })

  vim.g.neo_tree_remove_legacy_commands = 1

  fss.nnoremap('<c-n>', '<Cmd>Neotree toggle reveal<CR>')
  fss.nnoremap('-', '<Cmd>Neotree current %:p:h:h %:p<CR>')

  require('neo-tree').setup({
    sources = {
      'filesystem',
      'buffers',
      'git_status',
      'diagnostics',
    },
    source_selector = {
      winbar = true, -- toggle to show selector on winbar
      separator_active = ' ',
    },
    enable_git_status = true,
    git_status_async = true,
    event_handlers = {
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
      follow_current_file = true,
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        never_show = {
          '.DS_Store',
        },
      },
    },
    default_component_configs = {
      icon = {
        folder_empty = '',
      },
      modified = {
        symbol = icons.misc.circle .. ' ',
      },
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
      width = 45,
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
