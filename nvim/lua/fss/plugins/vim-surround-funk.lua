return function()
  vim.g.surround_funk_create_mappings = 0
  require('which-key').register({
    d = {
      name = '+dsf: function text object',
      s = {
        F = {
          '<Plug>(DeleteSurroundingFunction)',
          'delete surrounding function',
        },
        f = {
          '<Plug>(DeleteSurroundingFUNCTION)',
          'delete surrounding outer function',
        },
      },
    },
    c = {
      name = '+dsf: function text object',
      s = {
        F = {
          '<Plug>(ChangeSurroundingFunction)',
          'change surrounding function',
        },
        f = {
          '<Plug>(ChangeSurroundingFUNCTION)',
          'change outer surrounding function',
        },
      },
    },
  })
end
