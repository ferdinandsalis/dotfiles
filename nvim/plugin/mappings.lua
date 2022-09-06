if not fss then
  return
end

local fn = vim.fn
local api = vim.api
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

command('BufferCloseAll', function()
  vim.cmd(':bufdo :Bdelete')
end)

-- }}}
-- Pasting {{{
-- Paste in visual mode multiple times
xnoremap('p', 'pgvy')
nnoremap('p', 'P')
nnoremap('P', 'p')
-- Add Empty space above and below
nnoremap(
  '[<space>',
  [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]],
  'add space above'
)
nnoremap(
  ']<space>',
  [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]],
  'add space below'
)
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
-- Save & new files {{{
-- -----------------------------------------------------------------------------
nnoremap('<c-s>', ':silent! write<CR>')
-- Write and quit all files, ZZ is NOT equivalent to this
nnoremap('qa', '<cmd>qa<CR>')
--open a new file in the same directory
nnoremap(
  '<leader>nf',
  [[:e <C-R>=expand("%:p:h") . "/" <CR>]],
  { silent = false, desc = 'create new file' }
)
--open a new file in the same directory
nnoremap(
  '<leader>ns',
  [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]],
  { silent = false, desc = 'create new file in split' }
)
-- }}}
-- Quickfix {{{
-- Navigate between quickfix items
nnoremap(']q', '<cmd>cnext<CR>zz')
nnoremap('[q', '<cmd>cprev<CR>zz')
nnoremap(']l', '<cmd>lnext<cr>zz')
nnoremap('[l', '<cmd>lprev<cr>zz')
-- }}}
-- Tab Navigation {{{
nnoremap('<leader>tc', '<cmd>tabclose<CR>', 'close tab')
nnoremap(']t', '<cmd>tabprev<CR>', 'previous tab')
nnoremap('[t', '<cmd>tabnext<CR>', 'next tab')
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
nnoremap('<leader>ls', fss.toggle_qf_list, 'toggle location list')
nnoremap('<leader>li', fss.toggle_loc_list, 'toggle quickfix')
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
nnoremap(
  'j',
  [[(v:count > 1 ? 'm`' . v:count : '') . 'gj']],
  { expr = true, silent = true }
)
nnoremap(
  'k',
  [[(v:count > 1 ? 'm`' . v:count : '') . 'gk']],
  { expr = true, silent = true }
)
-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- but if already at the first character then jump to the beginning
--@see: https://github.com/yuki-yano/zero.nvim/blob/main/lua/zero.lua
nnoremap(
  '0',
  "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'",
  { expr = true }
)
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
        tnoremap('<C-h>', '<Cmd>wincmd h<CR>', opts)
        tnoremap('<C-j>', '<Cmd>wincmd j<CR>', opts)
        tnoremap('<C-k>', '<Cmd>wincmd k<CR>', opts)
        tnoremap('<C-l>', '<Cmd>wincmd l<CR>', opts)
        tnoremap(']t', '<Cmd>tablast<CR>')
        tnoremap('[t', '<Cmd>tabnext<CR>')
        tnoremap('<S-Tab>', '<Cmd>bprev<CR>')
        tnoremap('<leader><Tab>', '<Cmd>close \\| :bnext<cr>')
      end
    end,
  },
})
-- }}}
-- Grep Operator {{{
-- http://travisjeffery.com/b/2011/10/m-x-occur-for-vim/

---@param type string
---@return nil
function fss.mappings.grep_operator(type)
  local saved_unnamed_register = fn.getreg('@@')
  if type:match('v') then
    vim.cmd([[normal! `<v`>y]])
  elseif type:match('char') then
    vim.cmd([[normal! `[v`]y']])
  else
    return
  end
  -- Store the current window so if it changes we can restore it
  local win = api.nvim_get_current_win()
  vim.cmd.grep({
    fn.shellescape(fn.getreg('@@')) .. ' .',
    bang = true,
    mods = { silent = true },
  })
  fn.setreg('@@', saved_unnamed_register)
  if api.nvim_get_current_win() ~= win then
    vim.cmd.wincmd('p')
  end
end

nnoremap('<leader>g', function()
  vim.opt.operatorfunc = 'v:lua.fss.mappings.grep_operator'
  return 'g@'
end, { expr = true, desc = 'grep operator' })
xnoremap(
  '<leader>g',
  ':call v:lua.fss.mappings.grep_operator(visualmode())<CR>'
)
-- }}}

-- vim:foldmethod=marker
