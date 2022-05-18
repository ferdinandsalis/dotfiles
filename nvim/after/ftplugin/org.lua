require('which-key').register({
  ['<leader>'] = {
    o = {
      name = '+org',
      ['r'] = 'Refile subtree under cursor to destination',
      ['$'] = 'Archive subtree to archive file',
      ['t'] = 'Change tags of current headline',
      ['A'] = "toggle 'ARCHIVE' tag on current headline",
      ['o'] = 'Open hyperlink or date under cursor',
      i = {
        name = '+org-new',
        ['h'] = 'Add new headline after current subtree',
        ['T'] = 'Add new TODO headline on line right after current line',
        ['t'] = 'Add new TODO headline after current subtree',
      },
      ['K'] = 'Move subtree up',
      ['J'] = 'Move subtree down',
    },
    ['t'] = 'Toggle checkbox state',
    ['<CR>'] = 'Add headline, list item or checkbox (context aware)',
  },
  ['<C-a>'] = 'Increase date under cursor by 1 day',
  ['<C-x>'] = 'Decrease date under cursor by 1 day',
  ['<TAB>'] = 'Toggle folding on current headline',
  ['<S-TAB>'] = 'Toggle folding in whole file',
  ['<<'] = 'Promote headline',
  ['>>'] = 'Demote headline',
  ['<s'] = 'Promote whole subtree',
  ['>s'] = 'Demote whole subtree',
  ci = {
    d = 'Change date under cursor via calendar popup',
    t = 'Forward change TODO state of current headline',
    T = 'Backward change TODO state of current headline',
  },
}, {
  buffer = 0,
})
