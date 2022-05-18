if not vim.filetype then
  return
end

-- NOTE: The do_filetype_lua global variable activates the Lua filetype detection mechanism, which
-- runs before the legacy Vim script filetype detection.
vim.g.do_filetype_lua = 1

vim.filetype.add({
  filename = {
    ['.gitignore'] = 'conf',
    ['.envrc'] = 'env',
    ['Brewfile'] = 'ruby',
  },
  pattern = {
    ['*.env.*'] = 'env',
    ['*.conf'] = 'conf',
  },
  extension = {
    tsx = 'typescriptreact',
    ts = 'typescript',
  },
})
