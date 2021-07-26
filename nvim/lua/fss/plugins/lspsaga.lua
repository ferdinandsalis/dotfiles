return function()
  local saga = require 'lspsaga'

  saga.init_lsp_saga {
    use_saga_diagnostic_sign = false,
    finder_action_keys = {
      vsplit = 'v',
      split = 's',
      quit = { 'q', '<ESC>' },
    },
    code_action_icon = '💡',
    code_action_prompt = {
      enable = false,
      sign = false,
      virtual_text = false,
    },
  }

  require('fss.highlights').set_hl('LspSagaLightbulb', { guifg = 'NONE', guibg = 'NONE' })

  -- jump diagnostic
  fss.inoremap('<c-k>', "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>")
  fss.nnoremap('K', "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>")

  -- scroll down and up hover doc
  fss.nnoremap('<C-f>', [[<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>]])
  fss.nnoremap('<C-b>', [[<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>]])

  require('which-key').register {
    ['<leader>rn'] = { "<cmd>lua require('lspsaga.rename').rename()<CR>", 'lsp: rename' },
    ['<leader>ca'] = {
      "<cmd>lua require('lspsaga.codeaction').code_action()<CR>",
      'lsp: code action',
    },
    ['gp'] = {
      "<cmd>lua require'lspsaga.provider'.preview_definition()<CR>",
      'lsp: preview definition',
    },
    ['gh'] = { "<cmd>lua require'lspsaga.provider'.lsp_finder()<CR>", 'lsp: finder' },
    -- jump diagnostic
    [']c'] = {
      "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>",
      'lsp: previous diagnostic',
    },
    ['[c'] = {
      "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>",
      'lsp: next diagnostic',
    },
  }

  fss.augroup('LspSagaCursorCommands', {
    {
      events = { 'CursorHold' },
      targets = { '*' },
      command = "lua require('lspsaga.diagnostic').show_cursor_diagnostics()",
    },
  })
end
