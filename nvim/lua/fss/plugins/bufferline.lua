return function()
  local fn = vim.fn
  local groups = require('bufferline.groups')

  require('bufferline').setup({
    highlights = {
      info = { gui = 'undercurl' },
      info_selected = { gui = 'undercurl' },
      info_visible = { gui = 'undercurl' },
      warning = { gui = 'undercurl' },
      warning_selected = { gui = 'undercurl' },
      warning_visible = { gui = 'undercurl' },
      error = { gui = 'undercurl' },
      error_selected = { gui = 'undercurl' },
      error_visible = { gui = 'undercurl' },
    },
    options = {
      debug = {
        logging = true,
      },
      themable = true,
      navigation = { mode = 'uncentered' },
      mode = 'buffers', -- tabs
      sort_by = 'insert_after_current',
      right_mouse_command = 'vert sbuffer %d',
      show_buffer_icons = false,
      show_close_icon = false,
      show_buffer_close_icons = true,
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = false,
      diagnostics_update_in_insert = false,
      offsets = {
        {
          filetype = 'pr',
          highlight = 'PanelHeading',
        },
        {
          filetype = 'dbui',
          highlight = 'PanelHeading',
        },
        {
          filetype = 'undotree',
          text = 'Undotree',
          highlight = 'PanelHeading',
          text_align = 'left',
        },
        {
          filetype = 'neo-tree',
          text = 'Explorer',
          highlight = 'PanelHeading',
          text_align = 'left',
        },
        {
          filetype = 'DiffviewFiles',
          text = 'Diff',
          highlight = 'PanelHeading',
          text_align = 'left',
        },
        {
          filetype = 'flutterToolsOutline',
          text = 'Flutter Outline',
          highlight = 'PanelHeading',
          text_align = 'left',
        },
        {
          filetype = 'Outline',
          text = 'Symbols',
          highlight = 'PanelHeading',
          text_align = 'left',
        },
        {
          filetype = 'packer',
          text = 'Packer',
          highlight = 'PanelHeading',
          text_align = 'left',
        },
      },
      groups = {
        options = {
          toggle_hidden_on_enter = true,
        },
        items = {
          groups.builtin.pinned:with({ icon = '' }),
          groups.builtin.ungrouped,
          {
            name = 'Terraform',
            matcher = function(buf)
              return buf.name:match('%.tf') ~= nil
            end,
          },
          {
            name = 'SQL',
            matcher = function(buf)
              return buf.filename:match('%.sql$')
            end,
          },
          {
            name = 'tests',
            icon = '',
            matcher = function(buf)
              local name = buf.filename
              if name:match('%.sql$') == nil then
                return false
              end
              return name:match('_spec') or name:match('_test')
            end,
          },
          {
            name = 'docs',
            icon = '',
            matcher = function(buf)
              for _, ext in ipairs({ 'md', 'txt', 'org', 'norg', 'wiki' }) do
                if ext == fn.fnamemodify(buf.path, ':e') then
                  return true
                end
              end
            end,
          },
        },
      },
    },
  })

  require('which-key').register({
    ['gD'] = { '<Cmd>BufferLinePickClose<CR>', 'bufferline: delete buffer' },
    ['gb'] = { '<Cmd>BufferLinePick<CR>', 'bufferline: pick buffer' },
    ['<tab>'] = { '<Cmd>BufferLineCycleNext<CR>', 'bufferline: next' },
    ['<S-tab>'] = { '<Cmd>BufferLineCyclePrev<CR>', 'bufferline: prev' },
    ['[b'] = { '<Cmd>BufferLineMoveNext<CR>', 'bufferline: move next' },
    [']b'] = { '<Cmd>BufferLineMovePrev<CR>', 'bufferline: move prev' },
    ['<leader>on'] = {
      '<ESC>:execute "BufferLineCloseLeft" <bar> :execute "BufferLineCloseRight"<CR>',
      'bufferline: current only',
    },
    ['<leader>bp'] = {
      '<Cmd>BufferLineTogglePin<CR>',
      'bufferline: toggle pin',
    },
    ['<leader>1'] = { '<Cmd>BufferLineGoToBuffer 1<CR>', 'which_key_ignore' },
    ['<leader>2'] = { '<Cmd>BufferLineGoToBuffer 2<CR>', 'which_key_ignore' },
    ['<leader>3'] = { '<Cmd>BufferLineGoToBuffer 3<CR>', 'which_key_ignore' },
    ['<leader>4'] = { '<Cmd>BufferLineGoToBuffer 4<CR>', 'which_key_ignore' },
    ['<leader>5'] = { '<Cmd>BufferLineGoToBuffer 5<CR>', 'which_key_ignore' },
    ['<leader>6'] = { '<Cmd>BufferLineGoToBuffer 6<CR>', 'which_key_ignore' },
    ['<leader>7'] = { '<Cmd>BufferLineGoToBuffer 7<CR>', 'which_key_ignore' },
    ['<leader>8'] = { '<Cmd>BufferLineGoToBuffer 8<CR>', 'which_key_ignore' },
    ['<leader>9'] = { '<Cmd>BufferLineGoToBuffer 9<CR>', 'which_key_ignore' },
  })

  local H = require('fss.highlights')
  local bg_color = H.get('StatusLine', 'bg')
  local sep_color = H.alter_color(bg_color, -36)

  H.plugin('bufferline', {
    { BufferLineFill = { background = bg_color } },
    { BufferLineBackground = { background = bg_color } },
    -- Tab
    { BufferLineTab = { background = bg_color } },
    { BufferLineTabSelected = { background = 'background' } },
    { BufferLineTabClose = { background = bg_color } },
    -- Close Button
    { BufferLineCloseButton = { background = bg_color } },
    { BufferLineCloseButtonVisible = { background = bg_color } },
    { BufferLineCloseButtonSelected = { background = 'background' } },
    -- Buffer
    { BufferLineBuffer = { background = bg_color } },
    { BufferLineBufferVisible = { background = bg_color, bold = true } },
    { BufferLineBufferSelected = { background = 'background', bold = true } },
    -- Diagnostic
    { BufferLineDiagnostic = { background = bg_color } },
    { BufferLineDiagnosticVisible = { background = bg_color } },
    { BufferLineDiagnosticSelected = { background = 'background' } },
    -- Info
    { BufferLineInfo = { background = bg_color } },
    { BufferLineInfoVisible = { background = bg_color } },
    { BufferLineInfoSelected = { background = 'background' } },
    { BufferLineInfoDiagnostic = { background = bg_color } },
    { BufferLineInfoDiagnosticVisible = { background = bg_color } },
    { BufferLineInfoDiagnosticSelected = { background = 'background' } },
    -- Warning
    { BufferLineWarning = { background = bg_color } },
    { BufferLineWarningVisible = { background = bg_color } },
    { BufferLineWarningSelected = { background = 'background' } },
    { BufferLineWarningDiagnostic = { background = bg_color } },
    { BufferLineWarningDiagnosticVisible = { background = bg_color } },
    { BufferLineWarningDiagnosticSelected = { background = 'background' } },
    -- Error
    { BufferLineError = { background = bg_color } },
    { BufferLineErrorVisible = { background = bg_color } },
    { BufferLineErrorSelected = { background = 'background' } },
    { BufferLineErrorDiagnostic = { background = bg_color } },
    { BufferLineErrorDiagnosticVisible = { background = bg_color } },
    { BufferLineErrorDiagnosticSelected = { background = 'background' } },
    -- Hint
    { BufferLineHint = { background = bg_color } },
    { BufferLineHintVisible = { background = bg_color } },
    { BufferLineHintSelected = { background = 'background' } },
    { BufferLineHintDiagnostic = { background = bg_color } },
    { BufferLineHintDiagnosticVisible = { background = bg_color } },
    { BufferLineHintDiagnosticSelected = { background = 'background' } },
    -- Modified
    { BufferLineModified = { background = bg_color } },
    { BufferLineModifiedVisible = { background = bg_color } },
    { BufferLineModifiedSelected = { background = 'background' } },
    -- Duplicate
    { BufferLineDuplicate = { background = bg_color, bold = false, italic = false, }, },
    { BufferLineDuplicateVisible = { background = bg_color, bold = false, italic = false, }, },
    { BufferLineDuplicateSelected = { background = 'background' } },
    -- Separator
    {
      BufferLineSeparator = { foreground = sep_color, background = bg_color },
    },
    {
      BufferLineSeparatorVisible = {
        foreground = sep_color,
        background = bg_color,
      },
    },
    {
      BufferLineSeparatorSelected = {
        foreground = sep_color,
        background = bg_color,
      },
    },
    -- Indicator
    {
      BufferLineIndicatorSelected = {
        background = 'background',
        foreground = 'background',
      },
    },
    {
      BufferLineIndicatorVisible = {
        background = bg_color,
        foreground = bg_color,
      },
    },
    -- Pick
    { BufferLinePick = { background = bg_color } },
    { BufferLinePickVisible = { background = bg_color } },
    { BufferLinePickSelected = { background = 'background' } },
  })
end
