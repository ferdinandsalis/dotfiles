if not vim.filetype then
  return
end

vim.filetype.add({
  filename = {
    ['NEOGIT_COMMIT_EDITMSG'] = 'NeogitCommitMessage',
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
