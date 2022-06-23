return function()
  require('toggleterm').setup({
    open_mapping = [[<c-\>]],
    shade_filetypes = { 'none' },
    shade_terminals = false,
    direction = 'horizontal',
    insert_mappings = false,
    start_in_insert = true,
    highlights = {
      FloatBorder = { link = 'FloatBorder' },
      NormalFloat = { link = 'NormalFloat' },
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

  local float_handler = function(term)
    if vim.fn.mapcheck('jk', 't') ~= '' then
      vim.api.nvim_buf_del_keymap(term.bufnr, 't', 'jk')
      vim.api.nvim_buf_del_keymap(term.bufnr, 't', '<esc>')
    end
  end

  local Terminal = require('toggleterm.terminal').Terminal

  local lazygit = Terminal:new({
    cmd = 'lazygit',
    dir = 'git_dir',
    hidden = true,
    direction = 'float',
    on_open = float_handler,
  })

  local gh_dash = Terminal:new({
    cmd = 'gh dash',
    hidden = true,
    direction = 'float',
    on_open = float_handler,
    float_opts = {
      height = function()
        return math.floor(vim.o.lines * 0.8)
      end,
      width = function()
        return math.floor(vim.o.columns * 0.95)
      end,
    },
  })

  fss.nnoremap('<leader>ld', function()
    gh_dash:toggle()
  end, 'toggleterm: toggle github dashboard')

  fss.nnoremap('<leader>lg', function()
    lazygit:toggle()
  end, 'toggleterm: toggle lazygit')
end
