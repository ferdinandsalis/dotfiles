return function()
  -- this plugin is not safe to reload
  if vim.g.packer_compiled_loaded then
    return
  end
  local notify = require 'notify'
  ---@type table<string, fun(bufnr: number, notif: table, highlights: table)>
  local renderer = require 'notify.render'
  notify.setup {
    stages = 'fade_in_slide_out',
    timeout = 3000,
    render = function(bufnr, notif, highlights)
      if notif.title[1] == '' then
        return renderer.minimal(bufnr, notif, highlights)
      end
      return renderer.default(bufnr, notif, highlights)
    end,
  }
  vim.notify = notify
  require('telescope').load_extension 'notify'
  fss.nnoremap(
    '<leader>nd',
    notify.dismiss,
    { label = 'dismiss notifications' }
  )

  local P = fss.style.palette
  require('fss.highlights').plugin(
    'notify',
    {
      'NotifyERRORBorder',
      { background = P.bg_highlight, foreground = P.bg_highlight },
    },
    {
      'NotifyDEBUGBorder',
      { background = P.bg_highlight, foreground = P.bg_highlight },
    },
    {
      'NotifyWARNBorder',
      { background = P.bg_highlight, foreground = P.bg_highlight },
    },
    {
      'NotifyINFOBorder',
      { background = P.bg_highlight, foreground = P.bg_highlight },
    },
    {
      'NotifyTRACEBorder',
      { background = P.bg_highlight, foreground = P.bg_highlight },
    },
    { 'NotifyERRORBody', { background = P.bg_highlight } },
    { 'NotifyDEBUGBody', { background = P.bg_highlight } },
    { 'NotifyWARNBody', { background = P.bg_highlight } },
    { 'NotifyINFOBody', { background = P.bg_highlight } },
    { 'NotifyTRACEBody', { background = P.bg_highlight } }
  )
end
