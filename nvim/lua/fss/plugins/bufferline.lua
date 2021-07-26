return function()
  local function is_ft(b, ft)
    return vim.bo[b].filetype == ft
  end

  local function diagnostics_indicator(_, _, diagnostics)
    local result = {}
    local symbols = { error = ' ', warning = ' ', info = '' }
    for name, count in pairs(diagnostics) do
      if symbols[name] and count > 0 then
        table.insert(result, symbols[name] .. count)
      end
    end
    result = table.concat(result, ' ')
    return #result > 0 and ' ' .. result or ''
  end

  local function custom_filter(buf, buf_nums)
    local logs = vim.tbl_filter(function(b)
      return is_ft(b, 'log')
    end, buf_nums)
    if vim.tbl_isempty(logs) then
      return true
    end
    local tab_num = vim.fn.tabpagenr()
    local last_tab = vim.fn.tabpagenr '$'
    local is_log = is_ft(buf, 'log')
    if last_tab == 1 then
      return true
    end
    -- only show log buffers in secondary tabs
    return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
  end

  local highlights = require 'fss.highlights'
  local bg_color = highlights.darken_color(highlights.get_hl('Normal', 'bg'), -10)

  ---@diagnostic disable-next-line: unused-function
  local function sort_by_mtime(a, b)
    local astat = vim.loop.fs_stat(a.path)
    local bstat = vim.loop.fs_stat(b.path)
    local mod_a = astat and astat.mtime.sec or 0
    local mod_b = bstat and bstat.mtime.sec or 0
    return mod_a > mod_b
  end

  require('bufferline').setup {
    options = {
      view = 'multiwindow',
      sort_by = sort_by_mtime,
      mappings = false,
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = diagnostics_indicator,
      custom_filter = custom_filter,
      offsets = {
        {
          filetype = 'NvimTree',
          text = 'Explorer',
          highlight = 'PanelHeading',
          text_align = 'left',
          padding = 1,
        },
        {
          filetype = 'DiffviewFiles',
          text = 'Diff',
          highlight = 'PanelHeading',
          text_align = 'left',
          padding = 1,
        },
      },
      buffer_close_icon = '',
      modified_icon = '●',
      close_icon = '',
      left_trunc_marker = '',
      right_trunc_marker = '',
      max_name_length = 18,
      max_prefix_length = 15,
      tab_size = 20,
      right_mouse_command = 'vert sbuffer %d',
      show_close_icon = false,
      show_buffer_close_icons = true,
      persist_buffer_sort = true,
      separator_style = { '', '' },
      always_show_bufferline = true,
    },
    highlights = {
      fill = { guibg = bg_color },
    },
  }

  require('which-key').register {
    ['gb'] = { '<cmd>BufferLinePick<CR>', 'bufferline: pick buffer' },
    ['<leader><tab>'] = { '<cmd>BufferLineCycleNext<CR>', 'bufferline: next' },
    ['<S-tab>'] = { '<cmd>BufferLineCyclePrev<CR>', 'bufferline: prev' },
    ['[b'] = { '<cmd>BufferLineMoveNext<CR>', 'bufferline: move next' },
    [']b'] = { '<cmd>BufferLineMovePrev<CR>', 'bufferline: move prev' },
  }
end
