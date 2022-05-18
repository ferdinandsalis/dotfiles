return function()
  require('window-picker').setup({
    autoselect_one = true,
    include_current = false,
    filter_rules = {
      bo = {
        filetype = {
          'neo-tree',
          'neo-tree-popup',
          'notify',
          'quickfix',
          'incline',
        },
        buftype = { 'terminal' },
      },
    },
    other_win_hl_color = require('fss.highlights').get_hl('Visual', 'bg'),
  })
end
