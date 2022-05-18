return function()
  vim.g.projectionist_heuristics = {
    ['*.js'] = {
      ['*.js'] = { alternate = 'tests/{}.test.js', type = 'source' },
      ['tests/*.test.js'] = {
        alternate = '{}.js',
        type = 'test',
        template = {
          "describe('{}', function() {\n",
          "  test('should be true', () => {\n",
          '    expect(true).toBe(true);\n',
          '  });\n',
          '});\n',
        },
      },
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
