
-- Color Scheme {{{1
if fss.plugin_installed('tokyonight.nvim') then
  vim.g.tokyonight_transparent = false
  vim.g.tokyonight_style = "storm"
  vim.g.tokyonight_sidebars = { "neo-tree", "qf", "terminal", "packer" }
  vim.g.tokyonight_dark_sidebar = true
  vim.cmd('colorscheme tokyonight')
end
