return function()
  local colors = require('tokyonight.colors').setup()

  require('scrollbar').setup({
    handle = {
      color = '#32384F',
    },
    track = {
      color = colors.bg_visual,
    },
    -- NOTE: If telescope is not explicitly excluded this garbles input into its prompt buffer
    excluded_filetypes = {
      'packer',
      'TelescopePrompt',
      'NvimTree',
    },
    excluded_buftypes = {
      'nofile',
      'terminal',
      'prompt',
    },
    marks = {
      Search = { color = colors.orange },
      Error = { color = colors.error },
      Warn = { color = colors.warning },
      Info = { color = colors.info },
      Hint = { color = colors.hint },
      Misc = { color = colors.purple },
    },
  })
end
