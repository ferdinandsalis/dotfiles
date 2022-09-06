return function()
  local null_ls = require('null-ls')
  null_ls.setup({
    debounce = 150,
    sources = {
      null_ls.builtins.diagnostics.buf,
      null_ls.builtins.diagnostics.zsh,
      null_ls.builtins.code_actions.gitsigns,
      null_ls.builtins.formatting.mix,
      null_ls.builtins.formatting.stylua.with({
        condition = function()
          return fss.executable('stylua')
        end,
      }),
      null_ls.builtins.formatting.raco_fmt,
      null_ls.builtins.formatting.prettier_d_slim.with({
        filetypes = {
          'html',
          'json',
          'yaml',
          'graphql',
          'markdown',
          'javascript',
          'javascriptreact',
          'typescript',
          'typescriptreact',
        },
        condition = function()
          return fss.executable('prettier_d_slim')
        end,
      }),
    },
  })
end
