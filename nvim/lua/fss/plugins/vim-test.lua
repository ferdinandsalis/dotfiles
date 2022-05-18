local M = {}

M.setup = function()
  require('which-key').register({
    t = {
      name = '+vim-test',
      f = 'test: file',
      n = 'test: nearest',
      s = 'test: suite',
    },
  }, {
    prefix = '<localleader>',
  })
end

M.config = function()
  -- vim.cmd [[
  --         function! ToggleTermStrategy(cmd) abort
  --           call luaeval("require('toggleterm').exec(_A[1])", [a:cmd])
  --         endfunction
  --         let g:test#custom_strategies = {'toggleterm': function('ToggleTermStrategy')}
  --       ]]
  -- vim.g['test#strategy'] = 'toggleterm'
  vim.g['test#strategy'] = 'kitty'
  vim.g['test#javascript#runner'] = 'jest'
  fss.nnoremap('<localleader>tf', '<cmd>TestFile<CR>')
  fss.nnoremap('<localleader>tn', '<cmd>TestNearest<CR>')
  fss.nnoremap('<localleader>ts', '<cmd>TestSuite<CR>')
end

return M
