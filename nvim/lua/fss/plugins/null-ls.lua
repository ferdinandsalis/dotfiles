return function()
  local null_ls = require('null-ls')
  local builtins = null_ls.builtins
  null_ls.setup({
    debug = true,
    debounce = 150,
    on_attach = fss.lsp.on_attach,
    sources = {
      builtins.hover.dictionary,
      builtins.diagnostics.zsh,
      builtins.diagnostics.write_good,
      builtins.code_actions.gitsigns,
      builtins.formatting.mix,
      builtins.formatting.prettier,
      null_ls.builtins.formatting.stylua.with({
        condition = function(_utils)
          return fss.executable('stylua')
            and _utils.root_has_file({ 'stylua.toml', '.stylua.toml' })
        end,
      }),
    },
  })
end
