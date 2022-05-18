return function()
  -- local H = require 'fss.highlights'
  -- H.plugin('trouble', {
  --   TroubleNormal = { link = 'PanelBackground' },
  --   TroubleText = { link = 'PanelBackground' },
  --   TroubleIndent = { link = 'PanelVertSplit' },
  --   TroubleFoldIcon = { foreground = 'yellow', bold = true },
  --   TroubleLocation = { foreground = H.get_hl('Comment', 'fg') },
  -- })
  local trouble = require('trouble')
  fss.nnoremap('<leader>ld', '<cmd>TroubleToggle workspace_diagnostics<CR>')
  fss.nnoremap('<leader>lr', '<cmd>TroubleToggle lsp_references<CR>')
  fss.nnoremap(']d', function()
    trouble.previous({ skip_groups = true, jump = true })
  end)
  fss.nnoremap('[d', function()
    trouble.next({ skip_groups = true, jump = true })
  end)
  trouble.setup({ auto_close = true, auto_preview = false })
end
