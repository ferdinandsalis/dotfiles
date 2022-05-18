return function()
  -- this plugin is not safe to reload
  if vim.g.packer_compiled_loaded then
    return
  end
  local notify = require('notify')
  ---@type table<string, fun(bufnr: number, notif: table, highlights: table)>
  local renderer = require('notify.render')
  notify.setup({
    stages = 'fade_in_slide_out',
    timeout = 3000,
    render = function(bufnr, notif, highlights)
      if notif.title[1] == '' then
        return renderer.minimal(bufnr, notif, highlights)
      end
      return renderer.default(bufnr, notif, highlights)
    end,
  })
  vim.notify = notify
  require('telescope').load_extension('notify')
  fss.nnoremap('<leader>nd', notify.dismiss, {
    desc = 'dismiss notifications',
  })

  local palette = fss.style.palette
  require('fss.highlights').plugin('notify', {
    NotifyERRORBorder = {
      background = palette.bg_highlight,
      foreground = palette.bg_highlight,
    },
    NotifyDEBUGBorder = {
      background = palette.bg_highlight,
      foreground = palette.bg_highlight,
    },
    NotifyWARNBorder = {
      background = palette.bg_highlight,
      foreground = palette.bg_highlight,
    },
    NotifyINFOBorder = {
      background = palette.bg_highlight,
      foreground = palette.bg_highlight,
    },
    NotifyTRACEBorder = {
      background = palette.bg_highlight,
      foreground = palette.bg_highlight,
    },
    NotifyERRORBody = {
      background = palette.bg_highlight,
    },
    NotifyDEBUGBody = {
      background = palette.bg_highlight,
    },
    NotifyWARNBody = {
      background = palette.bg_highlight,
    },
    NotifyINFOBody = {
      background = palette.bg_highlight,
    },
    NotifyTRACEBody = {
      background = palette.bg_highlight,
    },
  })
end
