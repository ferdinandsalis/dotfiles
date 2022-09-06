return function()
  require('fss.highlights').plugin('whichkey', {
    theme = {
      ['*'] = {
        { WhichkeyFloat = { link = 'NormalFloat' } },
      },
    },
  })

  local wk = require('which-key')
  wk.setup({
    plugins = { spelling = { enabled = true } },
    window = { border = fss.style.current.border },
    layout = { align = 'center' },
  })

  wk.register({
    ['<space><space>'] = 'toggle fold under cursor',

    ['<leader>'] = {
      name = 'leader',
      b = 'buffer management hydra',
      E = 'show token under the cursor',
      g = 'grep word under the cursor',
      z = 'folds hydra',
      c = { name = '+code-action' },
      d = { name = '+debug', h = 'dap hydra' },
      f = { name = '+telescope' },
      h = { name = '+git-action' },
      n = { name = '+new' },
      q = { name = '+quit' },
      l = { name = '+list' },
      i = { name = '+iswap' },
      r = { name = '+lsp-refactor' },
      o = { name = '+only' },
      t = { name = '+tab' },
    },

    ['<localleader>'] = {
      name = 'local leader',
      G = 'Git hydra',
      z = 'center view port',
      d = { name = '+dap' },
      g = { name = '+git' },
      n = { name = '+neogen' },
      o = { name = '+neorg' },
      t = { name = '+neotest' },
    },
  })
end
