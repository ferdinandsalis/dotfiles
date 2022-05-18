local M = {}

M.setup = function()
  -- https://observablehq.com/@d3/color-schemes?collection=@d3/d3-scale-chromatic
  -- NOTE: this must be set in the setup function or it will crash nvim...
  -- require('fss.highlights').plugin(
  --   'Headlines',
  --   { 'Headline1', { background = '#003c30', foreground = 'White' } },
  --   { 'Headline2', { background = '#00441b', foreground = 'White' } },
  --   { 'Headline3', { background = '#084081', foreground = 'White' } },
  --   { 'Dash', { background = '#0b60a1', bold = true } }
  -- )
end

M.config = function()
  require('headlines').setup({
    markdown = {
      headline_highlights = { 'Headline1', 'Headline2', 'Headline3' },
    },
    yaml = {
      dash_pattern = '^---+$',
      dash_highlight = 'Dash',
      dash_string = '-',
    },
  })
end

return M
