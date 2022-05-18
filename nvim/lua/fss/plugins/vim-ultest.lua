local M = {}

M.config = function()
  vim.cmd('UpdateRemotePlugins')
  local test_patterns = { '*.test.*', '*_test.*', '*_spec.*' }
  fss.augroup('UltestTests', {
    {
      event = 'BufWritePost',
      pattern = test_patterns,
      command = 'UltestNearest',
    },
  })
  fss.nmap(']T', '<Plug>(ultest-next-fail)', {
    desc = 'ultest: next failure',
    buffer = 0,
  })
  fss.nmap('[T', '<Plug>(ultest-prev-fail)', {
    desc = 'ultest: previous failure',
    buffer = 0,
  })

  local H = require('fss.highlights')
  local P = fss.style.palette
  H.plugin('ultest', {
    UltestSummaryInfo = { foreground = P.blue, italic = true },
    UltestSummaryNamespace = {
      foreground = P.magenta,
      italic = false,
      bold = true,
    },
    UltestSummaryFile = { foreground = P.blue, italic = true },
    UltestFail = { foreground = P.red },
    UltestPass = { foreground = P.green },
    UltestRunning = { foreground = P.yellow },
  })

  fss.nnoremap('<localleader><localleader>', '<cmd>Ultest<CR>')
  fss.nnoremap('<localleader>un', '<cmd>UltestNearest<CR>')
  fss.nnoremap('<localleader>us', '<cmd>UltestSummary<CR>')
end

M.setup = function()
  vim.g.ultest_use_pty = 1
  vim.g.ultest_virtual_text = 0
  vim.g.ultest_summary_width = 80
  vim.g.ultest_running_sign = ''
end

return M
