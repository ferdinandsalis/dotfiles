if not vim.filetype then
  return
end

-- NOTE: A value of 0 for this variable disables filetype.vim. A value of 1 disables both filetype.vim
-- and filetype.lua (which you probably don’t want).
vim.g.did_load_filetypes = 0

-- NOTE: The do_filetype_lua global variable activates the Lua filetype detection mechanism, which
-- runs before the legacy Vim script filetype detection.
vim.g.do_filetype_lua = 1

vim.filetype.add {
  filename = {
    ['.gitignore'] = 'conf',
    ['.env'] = 'sh',
  },
  extension = {
    tsx = "typescriptreact",
    ts = "typescript"
  }
}
