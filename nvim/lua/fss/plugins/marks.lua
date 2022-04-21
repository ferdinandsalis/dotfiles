return function()
  require('fss.highlights').plugin('marks', {
    MarkSignHL = { foreground = fss.style.palette.red },
  })
  require('which-key').register({
    m = {
      name = '+marks',
      b = { '<Cmd>MarksListBuf<CR>', 'list buffer' },
      g = { '<Cmd>MarksQFListGlobal<CR>', 'list global' },
      ['0'] = { '<Cmd>BookmarksQFList 0<CR>', 'list bookmark' },
    },
  }, { prefix = '<leader>' })
  require('marks').setup {
    -- NOTE: Don't use a builtin marks as they add a sign column to *all* windows
    -- regardless of if there is a valid sign in that window or not
    -- builtin_marks = { "'" },
    excluded_filetypes = {
      'NeogitStatus',
      'NeogitCommitMessage',
      'toggleterm',
    },
    bookmark_0 = {
      sign = '⚑',
      virt_text = 'bookmark',
    },
  }
end
