return function()
  require('fss.highlights').plugin('marks', {
    { MarkSignHL = { link = 'Directory' } },
    { MarkSignNumHL = { link = 'Directory' } },
  })

  fss.nnoremap('<leader>mb', '<Cmd>MarksListBuf<CR>', 'list buffer')
  fss.nnoremap('<leader>mg', '<Cmd>MarksQFListGlobal<CR>', 'list global')
  fss.nnoremap('<leader>m0', '<Cmd>BookmarksQFList 0<CR>', 'list bookmark')

  require('marks').setup({
    force_write_shada = false, -- This can cause data loss
    excluded_filetypes = {
      'NeogitStatus',
      'NeogitCommitMessage',
      'toggleterm',
    },
    bookmark_0 = {
      sign = '⚑',
      virt_text = '',
    },
    mappings = {
      annotate = 'm?',
    },
  })
end
