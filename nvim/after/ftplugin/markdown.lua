vim.opt_local.spell = true
vim.opt_local.number = false
vim.opt_local.relativenumber = false

local args = { buffer = 0 }

fss.onoremap('ih', [[:<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>]], args)
fss.onoremap('ah', [[:<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rg_vk0"<cr>]], args)
fss.onoremap('aa', [[:<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rg_vk0"<cr>]], args)
fss.onoremap('ia', [[:<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rkvg_"<cr>]], args)

if fss.plugin_loaded('markdown-preview.nvim') then
  fss.nmap('<localleader>p', '<Plug>MarkdownPreviewToggle', args)
end

fss.ftplugin_conf(
  'cmp',
  function(cmp)
    cmp.setup.filetype('markdown', {
      sources = cmp.config.sources({
        { name = 'dictionary' },
        { name = 'spell' },
        { name = 'emoji' },
      }, {
        { name = 'buffer' },
      }),
    })
  end
)

fss.ftplugin_conf('nvim-surround', function(surround)
  surround.buffer_setup({
    delimiters = {
      pairs = {
        ['l'] = function()
          return {
            '[',
            '](' .. vim.fn.getreg('*') .. ')',
          }
        end,
      },
    },
  })
end)
