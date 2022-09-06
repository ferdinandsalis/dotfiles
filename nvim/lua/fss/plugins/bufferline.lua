return function()
  local fn = vim.fn
  local groups = require('bufferline.groups')

  local function offset(name, ft)
    return {
      filetype = ft,
      text = name,
      text_align = 'left',
      seperator = true,
      highlight = 'PanelDarkHeading',
    }
  end

  require('bufferline').setup({
    highlights = {
      info = { undercurl = false },
      info_selected = { undercurl = false },
      info_visible = { undercurl = false },
      warning = { undercurl = false },
      warning_selected = { undercurl = false },
      warning_visible = { undercurl = false },
      error = { undercurl = false },
      error_selected = { undercurl = false },
      error_visible = { undercurl = false },
    },
    options = {
      debug = { logging = true },
      hover = { enabled = true, reveal = { 'close' } },
      themable = true,
      navigation = { mode = 'uncentered' },
      mode = 'buffers', -- tabs
      sort_by = 'insert_after_current',
      right_mouse_command = 'vert sbuffer %d',
      show_buffer_icons = false,
      show_close_icon = false,
      show_buffer_close_icons = true,
      -- diagnostics = 'nvim_lsp',
      diagnostics_indicator = false,
      diagnostics_update_in_insert = false,
      offsets = {
        offset('DATABASE VIEWER', 'dbui'),
        offset('UNDOTREE', 'undotree'),
        offset('EXPLORER', 'neo-tree'),
        offset('DIFF VIEW', 'DiffviewFiles'),
        offset('PACKER', 'packer'),
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

  fss.nnoremap(
    'gD',
    '<Cmd>BufferLinePickClose<CR>',
    'bufferline: delete buffer'
  )
  fss.nnoremap('gb', '<Cmd>BufferLinePick<CR>', 'bufferline: pick buffer')
  fss.nnoremap('<tab>', '<Cmd>BufferLineCycleNext<CR>', 'bufferline: next')
  fss.nnoremap('<S-tab>', '<Cmd>BufferLineCyclePrev<CR>', 'bufferline: prev')
  fss.nnoremap('[b', '<Cmd>BufferLineMoveNext<CR>', 'bufferline: move next')
  fss.nnoremap(']b', '<Cmd>BufferLineMovePrev<CR>', 'bufferline: move prev')
  fss.nnoremap(
    '<leader>on',
    '<ESC>:execute "BufferLineCloseLeft" <bar> :execute "BufferLineCloseRight"<CR>',
    'bufferline: current only'
  )
  fss.nnoremap('<leader>1', '<Cmd>BufferLineGoToBuffer 1<CR>')
  fss.nnoremap('<leader>2', '<Cmd>BufferLineGoToBuffer 2<CR>')
  fss.nnoremap('<leader>3', '<Cmd>BufferLineGoToBuffer 3<CR>')
  fss.nnoremap('<leader>4', '<Cmd>BufferLineGoToBuffer 4<CR>')
  fss.nnoremap('<leader>5', '<Cmd>BufferLineGoToBuffer 5<CR>')
  fss.nnoremap('<leader>6', '<Cmd>BufferLineGoToBuffer 6<CR>')
  fss.nnoremap('<leader>7', '<Cmd>BufferLineGoToBuffer 7<CR>')
  fss.nnoremap('<leader>8', '<Cmd>BufferLineGoToBuffer 8<CR>')
  fss.nnoremap('<leader>9', '<Cmd>BufferLineGoToBuffer 9<CR>')

  local H = require('fss.highlights')
  local bg_color = H.get('StatusLine', 'bg')
  local sep_color = H.alter_color(bg_color, -36)

  H.plugin('bufferline', {
    theme = {
      ['*'] = {
        { BufferLineFill = { background = bg_color } },
        { BufferLineBackground = { background = bg_color } },
        { BufferLineNumbers = { background = bg_color } },
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
        {
          BufferLineBufferSelected = {
            background = 'background',
            bold = true,
            -- underline = true,
          },
        },
        -- Diagnostic
        { BufferLineDiagnostic = { background = bg_color } },
        { BufferLineDiagnosticVisible = { background = bg_color } },
        {
          BufferLineDiagnosticSelected = {
            background = 'background',
            -- underline = true,
          },
        },
        -- Info
        { BufferLineInfo = { background = bg_color } },
        { BufferLineInfoVisible = { background = bg_color } },
        {
          BufferLineInfoSelected = {
            background = 'background',
            -- underline = true,
          },
        },
        { BufferLineInfoDiagnostic = { background = bg_color } },
        { BufferLineInfoDiagnosticVisible = { background = bg_color } },
        { BufferLineInfoDiagnosticSelected = { background = 'background' } },
        -- Warning
        { BufferLineWarning = { background = bg_color } },
        { BufferLineWarningVisible = { background = bg_color } },
        {
          BufferLineWarningSelected = {
            background = 'background',
            -- underline = true,
          },
        },
        { BufferLineWarningDiagnostic = { background = bg_color } },
        { BufferLineWarningDiagnosticVisible = { background = bg_color } },
        {
          BufferLineWarningDiagnosticSelected = { background = 'background' },
        },
        -- Error
        { BufferLineError = { background = bg_color } },
        { BufferLineErrorVisible = { background = bg_color } },
        {
          BufferLineErrorSelected = {
            background = 'background',
            -- underline = true,
          },
        },
        { BufferLineErrorDiagnostic = { background = bg_color } },
        { BufferLineErrorDiagnosticVisible = { background = bg_color } },
        { BufferLineErrorDiagnosticSelected = { background = 'background' } },
        -- Hint
        { BufferLineHint = { background = bg_color } },
        { BufferLineHintVisible = { background = bg_color } },
        {
          BufferLineHintSelected = {
            background = 'background',
            -- underline = true,
          },
        },
        { BufferLineHintDiagnostic = { background = bg_color } },
        { BufferLineHintDiagnosticVisible = { background = bg_color } },
        { BufferLineHintDiagnosticSelected = { background = 'background' } },
        -- Modified
        { BufferLineModified = { background = bg_color } },
        { BufferLineModifiedVisible = { background = bg_color } },
        { BufferLineModifiedSelected = { background = 'background' } },
        -- Duplicate
        {
          BufferLineDuplicate = {
            background = bg_color,
            bold = false,
            italic = false,
          },
        },
        {
          BufferLineDuplicateVisible = {
            background = bg_color,
            bold = false,
            italic = false,
          },
        },
        {
          BufferLineDuplicateSelected = {
            background = 'background',
            -- underline = true,
          },
        },
        -- Separator
        {
          BufferLineSeparator = {
            foreground = sep_color,
            background = bg_color,
          },
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
            background = 'background',
          },
        },
        -- Indicator
        {
          BufferLineIndicator = {
            background = bg_color,
            foreground = sep_color,
          },
        },
        {
          BufferLineIndicatorSelected = {
            background = 'background',
            foreground = 'background',
          },
        },
        {
          BufferLineIndicatorVisible = {
            background = bg_color,
            foreground = sep_color,
          },
        },
        -- Pick
        { BufferLinePick = { background = bg_color, foreground = bg_color } },
        { BufferLinePickVisible = { background = bg_color } },
        { BufferLinePickSelected = { background = 'background' } },
      },
    },
  })
end
