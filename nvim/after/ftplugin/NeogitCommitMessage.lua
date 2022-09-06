vim.wo.list = false
vim.wo.number = false
vim.wo.relativenumber = false
vim.wo.spell = true
vim.wo.colorcolumn = '50,72'
vim.bo.spelllang = 'en_gb'

-- Schedule this call as highlights are not set correctly if there is not a delay
vim.schedule(function()
  require('fss.highlights').win_hl.set('gitcommit', 0, {
    { VirtColumn = { fg = { from = 'Variable' } } },
  })
end)

fss.ftplugin_conf('cmp', function(cmp)
  cmp.setup.filetype('NeogitCommitMessage', {
    sources = cmp.config.sources({
      { name = 'git' },
      { name = 'luasnip' },
      { name = 'dictionary' },
      { name = 'spell' },
    }, {
      { name = 'buffer' },
    }),
  })
end)
