return function()
  vim.g.copilot_no_tab_map = true

  fss.imap('<c-h>', [[copilot#Accept("\<CR>")]], {
    expr = true,
    script = true,
  })

  fss.imap('<Plug>(as-copilot-accept)', "copilot#Accept('<Tab>')", { expr = true })
  fss.inoremap('<M-]>', '<Plug>(copilot-next)')
  fss.inoremap('<M-[>', '<Plug>(copilot-previous)')
  fss.inoremap('<C-\\>', '<Cmd>vertical Copilot panel<CR>')

  vim.g.copilot_filetypes = {
    ['*'] = true,
    ['gitcommit'] = false,
    ['NeogitCommitMessage'] = false,
    ['neo-tree-popup'] = false,
  }
end
