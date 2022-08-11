return function()
  require('toggleterm').setup({
    open_mapping = [[<c-\>]],
    shade_terminals = false,
    direction = 'horizontal',
    persist_mode = true,
    insert_mappings = false,
    start_in_insert = true,
    winbar = {
      enabled = true,
    },
    highlights = {
      Normal = { link = 'PanelBackground' },
      FloatBorder = { link = 'PanelBackground' },
      NormalFloat = { link = 'PanelBackground' },
      EndOfBuffer = { link = 'PanelBackground' },
      StatusLine = { link = 'PanelSt' },
      StatusLineNC = { link = 'PanelStNC' },
      WinBar = { link = 'PanelBackground' },
      WinBarNC = { link = 'PanelBackground' },
      SignColumn = { link = 'PanelBackground' },
    },
    float_opts = {
      border = fss.style.current.border,
      winblend = 3,
    },
    size = function(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
  })
end
