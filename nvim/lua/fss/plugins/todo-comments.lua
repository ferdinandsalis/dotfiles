return function()
  fss.block_reload(function()
    require('todo-comments').setup({
      highlight = {
        exclude = { 'org', 'norg', 'markdown' },
      },
    })
    fss.nnoremap('<leader>lt', '<Cmd>TodoTrouble<CR>', 'trouble: todos')
  end)
end
