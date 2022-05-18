return function()
  local function diagnostics_indicator(_, _, diagnostics)
    local symbols = { error = ' ', warning = ' ', info = ' ' }
    local result = {}
    for name, count in pairs(diagnostics) do
      if symbols[name] and count > 0 then
        table.insert(result, symbols[name] .. count)
      end
    end
    result = table.concat(result, ' ')
    return #result > 0 and result or ''
  end

  local function custom_filter(buf, buf_nums)
    local logs = vim.tbl_filter(function(b)
      return vim.bo[b].filetype == 'log'
    end, buf_nums)
    if vim.tbl_isempty(logs) then
      return true
    end
    local tab_num = vim.fn.tabpagenr()
    local last_tab = vim.fn.tabpagenr('$')
    local is_log = vim.bo[buf].filetype == 'log'
    if last_tab == 1 then
      return true
    end
    -- only show log buffers in secondary tabs
    return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
  end

  require('bufferline').setup({
    options = {
      themable = true,
      mode = 'buffers', -- tabs
      sort_by = 'insert_after_current',
      right_mouse_command = 'vert sbuffer %d',
      show_buffer_icons = false,
      show_close_icon = false,
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = diagnostics_indicator,
      diagnostics_update_in_insert = false,
      custom_filter = custom_filter,
      offsets = {
        {
          filetype = 'neo-tree',
          text = '',
        },
        {
          filetype = 'undotree',
          text = '',
        },
        {
          filetype = 'DiffviewFiles',
          text = '',
        },
        {
          filetype = 'Outline',
          text = 'Symbols',
        },
        {
          filetype = 'packer',
          text = '',
        },
      },
    },
  })

  require('which-key').register({
    ['<leader>on'] = {
      [[:BufferLineCloseLeft<cr> <bar> :BufferLineCloseRight<cr>]],
      'bufferline: close all but current',
    },
    ['gD'] = { '<Cmd>BufferLinePickClose<CR>', 'bufferline: delete buffer' },
    ['gb'] = { '<Cmd>BufferLinePick<CR>', 'bufferline: pick buffer' },
    ['<tab>'] = { '<Cmd>BufferLineCycleNext<CR>', 'bufferline: next' },
    ['<S-tab>'] = { '<Cmd>BufferLineCyclePrev<CR>', 'bufferline: prev' },
    ['[b'] = { '<Cmd>BufferLineMoveNext<CR>', 'bufferline: move next' },
    [']b'] = { '<Cmd>BufferLineMovePrev<CR>', 'bufferline: move prev' },
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

  local colors = fss.style.palette
  require('fss.highlights').plugin('bufferline', {
    BufferLineFill = {
      background = colors.bg_dark,
    },
    BufferLineIndicatorSelected = {
      foreground = colors.bg,
      background = colors.bg,
    },
    BufferlineSeparatorSelected = {
      foreground = colors.fg_gutter,
    },
    BufferLineSeparator = {
      foreground = colors.bg,
      background = colors.bg_dark,
    },
  })
end
