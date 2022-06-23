local fn = vim.fn
local command = fss.command
local nmap = fss.nmap
local imap = fss.imap
local nnoremap = fss.nnoremap
local tnoremap = fss.tnoremap
local cnoremap = fss.cnoremap
local xnoremap = fss.xnoremap
local vnoremap = fss.vnoremap
local inoremap = fss.inoremap

-- Buffers {{{
-- -----------------------------------------------------------------------------
-- Switch between the last two files
nnoremap('<leader><leader>', [[<c-^>]])

command('BufferCurrentOnly', function()
  vim.cmd([[execute '%bdelete|edit#|bdelete#']])
end)
nnoremap('<leader>on', '<cmd>BufferCurrentOnly<CR>')

command('BufferCloseAll', function()
  vim.cmd(':bufdo :Bdelete')
end)

-- }}}
-- Moving lines {{{
-- -----------------------------------------------------------------------------
nnoremap('<a-k>', '<cmd>move-2<CR>==')
nnoremap('<a-j>', '<cmd>move+<CR>==')
xnoremap('<a-k>', ":move-2<CR>='[gv")
xnoremap('<a-j>', ":move'>+<CR>='[gv")
-- }}}
-- Folds {{{
-- -----------------------------------------------------------------------------
-- Evaluates whether there is a fold on the current line if so unfold it else return a normal space
nnoremap('<space><space>', [[@=(foldlevel('.')?'za':"\<Space>")<CR>]])
-- Refocus folds
nnoremap('<localleader>z', [[zMzvzz]])
-- Recursively open a top level fold no matter where the cursor is
nnoremap('zO', [[zCzO]])
-- }}}
-- Save {{{
-- -----------------------------------------------------------------------------
nnoremap('<c-s>', ':silent! write<CR>')
-- Write and quit all files, ZZ is NOT equivalent to this
nnoremap('qa', '<cmd>qa<CR>')
-- }}}
-- Quickfix {{{
-- Navigate between quickfix items
nnoremap(']q', '<cmd>cnext<CR>zz')
nnoremap('[q', '<cmd>cprev<CR>zz')
nnoremap(']l', '<cmd>lnext<cr>zz')
nnoremap('[l', '<cmd>lprev<cr>zz')
-- }}}
-- Tab Navigation {{{
nnoremap('<leader>tc', '<cmd>tabclose<CR>')
nnoremap(']t', '<cmd>tabprev<CR>')
nnoremap('[t', '<cmd>tabnext<CR>')
-- }}}
-- Positioning {{{
nmap(
  'zz',
  [[(winline() == (winheight (0) + 1)/ 2) ?  'zt' : (winline() == 1)? 'zb' : 'zz']],
  { expr = true }
)
-- }}}
-- Command mode {{{

-- smooth searching, allow tabbing between search results similar to using <c-g>
-- or <c-t> the main difference being tab is easier to hit and remapping those keys
-- to these would swallow up a tab mapping
cnoremap(
  '<Tab>',
  [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>/<C-r>/" : "<Tab>"]],
  { expr = true }
)
cnoremap(
  '<S-Tab>',
  [[getcmdtype() == "/" || getcmdtype() == "?" ? "<CR>?<C-r>/" : "<S-Tab>"]],
  { expr = true }
)
-- Smart mappings on the command line
cnoremap('w!!', [[w !sudo tee % >/dev/null]])
-- insert path of current file into a command
cnoremap('%%', "<C-r>=fnameescape(expand('%'))<cr>")
cnoremap('::', "<C-r>=fnameescape(expand('%:p:h'))<cr>/")
-- }}}
-- Lists {{{
-- -----------------------------------------------------------------------------
-- Toggle list
--- Utility function to toggle the location or the quickfix list
---@param list_type '"quickfix"' | '"location"'
---@return nil
function fss.toggle_list(list_type)
  local is_location_target = list_type == 'location'
  local prefix = is_location_target and 'l' or 'c'
  local L = vim.log.levels
  local is_open = fss.is_vim_list_open()
  if is_open then
    return fn.execute(prefix .. 'close')
  end
  local list = is_location_target and fn.getloclist(0) or fn.getqflist()
  if vim.tbl_isempty(list) then
    local msg_prefix = (is_location_target and 'Location' or 'QuickFix')
    return vim.notify(msg_prefix .. ' List is Empty.', L.WARN)
  end

  local winnr = fn.winnr()
  fn.execute(prefix .. 'open')
  if fn.winnr() ~= winnr then
    vim.cmd('wincmd p')
  end
end

nnoremap('<leader>ls', function()
  fss.toggle_list('quickfix')
end)
nnoremap('<leader>li', function()
  fss.toggle_list('location')
end)
-- }}}
-- Colorschme {{{
-- -----------------------------------------------------------------------------
command('ToggleBackground', function()
  vim.o.background = vim.o.background == 'dark' and 'light' or 'dark'
end)

-- }}}
-- Core Navigation {{{
-- -----------------------------------------------------------------------------
-- Store relative line number jumps in the jumplist.
nnoremap('j', [[(v:count > 1 ? 'm`' . v:count : '') . 'gj']], { expr = true, silent = true })
nnoremap('k', [[(v:count > 1 ? 'm`' . v:count : '') . 'gk']], { expr = true, silent = true })
-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- but if already at the first character then jump to the beginning
--@see: https://github.com/yuki-yano/zero.nvim/blob/main/lua/zero.lua
nnoremap('0', "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'", { expr = true })
-- when going to the end of the line in visual mode ignore whitespace characters
vnoremap('$', 'g_')
-- jk is escape, THEN move to the right to preserve the cursor position, unless
-- at the first column.  <esc> will continue to work the default way.
-- NOTE: this is a recursive mapping so anything bound (by a plugin) to <esc> still works
imap('jk', [[col('.') == 1 ? '<esc>' : '<esc>l']], { expr = true })
-- Toggle top/center/bottom
nmap(
  'zz',
  [[(winline() == (winheight (0) + 1)/ 2) ?  'zt' : (winline() == 1)? 'zb' : 'zz']],
  { expr = true }
)
-- }}}
-- Visual Shifting {{{
-- -----------------------------------------------------------------------------
-- does net exit visual mode
vnoremap('<', '<gv')
vnoremap('>', '>gv')
-- }}}
-- Marks {{{
-- -----------------------------------------------------------------------------
--Remap back tick for jumping to marks more quickly back
nnoremap("'", '`')
-- }}}
-- Completion {{{
-- -----------------------------------------------------------------------------
-- cycle the completion menu with <TAB>
inoremap('<tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
inoremap('<s-tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
-- }}}
-- Terminal {{{
-- -----------------------------------------------------------------------------
fss.augroup('AddTerminalMappings', {
  {
    event = { 'TermOpen' },
    pattern = { 'term://*' },
    command = function()
      if vim.bo.filetype == '' or vim.bo.filetype == 'toggleterm' then
        local opts = { silent = false, buffer = 0 }
        tnoremap('<esc>', [[<C-\><C-n>]], opts)
        tnoremap('jk', [[<C-\><C-n>]], opts)
        tnoremap('<C-h>', [[<C-\><C-n><C-W>h]], opts)
        tnoremap('<C-j>', [[<C-\><C-n><C-W>j]], opts)
        tnoremap('<C-k>', [[<C-\><C-n><C-W>k]], opts)
        tnoremap('<C-l>', [[<C-\><C-n><C-W>l]], opts)
        tnoremap(']t', [[<C-\><C-n>:tablast<CR>]])
        tnoremap('[t', [[<C-\><C-n>:tabnext<CR>]])
        tnoremap('<S-Tab>', [[<C-\><C-n>:bprev<CR>]])
        tnoremap('<leader><Tab>', [[<C-\><C-n>:close \| :bnext<cr>]])
      end
    end,
  },
})
-- }}}

-- vim:foldmethod=marker
