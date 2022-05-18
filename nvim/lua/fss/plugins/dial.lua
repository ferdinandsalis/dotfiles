return function()
  local dial = require('dial.map')
  local augend = require('dial.augend')
  local map = vim.keymap.set
  map('n', '<C-a>', dial.inc_normal(), { noremap = false })
  map('n', '<C-x>', dial.dec_normal(), { noremap = false })
  map('v', '<C-a>', dial.inc_visual(), { noremap = false })
  map('v', '<C-x>', dial.dec_visual(), { noremap = false })
  map('v', 'g<C-a>', dial.inc_gvisual(), { noremap = false })
  map('v', 'g<C-x>', dial.dec_gvisual(), { noremap = false })
  require('dial.config').augends:register_group({
    default = {
      augend.integer.alias.decimal,
      augend.integer.alias.hex,
      augend.date.alias['%Y/%m/%d'],
      augend.date.alias['%Y-%m-%d'],
      augend.constant.alias.bool,
      augend.constant.new({
        elements = { '&&', '||' },
        word = false,
        cyclic = true,
      }),
    },
  })
end
