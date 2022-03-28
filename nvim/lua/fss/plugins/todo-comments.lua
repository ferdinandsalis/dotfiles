return function()
  -- this plugin is not safe to reload
  if vim.g.packer_compiled_loaded then
    return
  end
  require('todo-comments').setup {
    highlight = {
      exclude = { 'org', 'orgagenda', 'vimwiki', 'markdown' },
    },
  }
  fss.nnoremap('<leader>lt', '<Cmd>TodoTrouble<CR>', 'trouble: todos')
end
