return function()
  local neotest = require('neotest')
  neotest.setup({
    diagnostic = {
      enabled = false,
    },
    icons = {
      running = fss.style.icons.misc.clock,
    },
    floating = {
      border = fss.style.current.border,
    },
    adapters = {
      require('neotest-plenary'),
      require('neotest-jest'),
      require('neotest-vim-test')({
        ignore_file_types = { 'lua' },
      }),
    },
  })
  local function open()
    neotest.output.open({ enter = true, short = false })
  end
  local function run_file()
    neotest.run.run(vim.fn.expand('%'))
  end
  fss.nnoremap('<localleader>ts', neotest.summary.toggle, 'neotest: run suite')
  fss.nnoremap('<localleader>to', open, 'neotest: output')
  fss.nnoremap('<localleader>tn', neotest.run.run, 'neotest: run')
  fss.nnoremap('<localleader>tf', run_file, 'neotest: run file')
  fss.nnoremap('[n', function()
    neotest.jump.prev({ status = 'failed' })
  end, 'jump to next failed test')
  fss.nnoremap(']n', function()
    neotest.jump.next({ status = 'failed' })
  end, 'jump to previous failed test')
end
