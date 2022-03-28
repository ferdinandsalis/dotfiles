return function()
  vim.g.copilot_filetypes = {
    ['*'] = false,
    gitcommit = false,
    NeogitCommitMessage = false,
    lua = true,
    javascript = true,
    typescript = true,
    typescriptreact = true,
    javascriptreact = true,
  }
  fss.imap('<c-h>', [[copilot#Accept("\<CR>")]], {
    expr = true,
    script = true,
  })
  vim.g.copilot_no_tab_map = true
  vim.g.copilot_assume_mapped = true
  vim.g.copilot_tab_fallback = ''
  require('fss.highlights').plugin(
    'copilot',
    { 'CopilotSuggestion', { link = 'Comment' } }
  )
end
