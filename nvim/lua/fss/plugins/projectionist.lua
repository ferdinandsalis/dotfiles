return function()
  vim.g.projectionist_heuristic = {
    ['*.js'] = {
      ['*.js'] = { alternate = 'tests/{}.test.js', ['type'] = 'source' },
      ['tests/*.test.js'] = { alternate = '{}.js', ['type'] = 'test' },
    },
  }

  require('which-key').register({
    A = { '<cmd>A<CR>', 'projectionist: edit alternate' },
    a = {
      name = '+projectionist',
      v = { '<cmd>AV<CR>', 'projectionist: vsplit alternate' },
      t = { '<cmd>Vtest<CR>', 'projectionist: vsplit test' },
    },
  }, {
    prefix = '<leader>',
  })
end
