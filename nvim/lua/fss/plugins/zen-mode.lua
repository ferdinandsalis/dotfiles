return function()
  require('zen-mode').setup({
    window = {
      backdrop = 1,
      width = 100,
      options = {
        number = false,
        relativenumber = false,
      },
    },
    {
      gitsigns = true,
    },
  })
  require('which-key').register({
    ['<leader>ze'] = { '<cmd>ZenMode<CR>', 'Zen' },
  })
end
