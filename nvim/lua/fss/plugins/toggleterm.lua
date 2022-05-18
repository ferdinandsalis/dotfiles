return function()
  require('toggleterm').setup({
    open_mapping = [[<c-\>]],
    shade_filetypes = { 'none' },
    direction = 'horizontal',
    insert_mappings = false,
    start_in_insert = true,
    float_opts = { border = 'rounded', winblend = fss.style.float.blend },
    size = function(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
  })
end
