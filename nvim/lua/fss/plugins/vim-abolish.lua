return function()
  local opts = { silent = false }
  fss.nnoremap('<localleader>[', ':S/<C-R><C-W>//<LEFT>', opts)
  fss.nnoremap('<localleader>]', ':%S/<C-r><C-w>//c<left><left>', opts)
  fss.xnoremap('<localleader>[', [["zy:%S/<C-r><C-o>"//c<left><left>]], opts)
end
