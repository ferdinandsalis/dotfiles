return function()
  local wk = require('which-key')
  wk.setup({
    plugins = {
      spelling = {
        enabled = true,
      },
    },
    window = {
      border = fss.style.current.border,
    },
    layout = {
      align = 'center',
    },
  })
end
