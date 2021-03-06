local fn = vim.fn
local api = vim.api
local command = fss.command
local fmt = string.format

local nmap = fss.nmap
local nnoremap = fss.nnoremap
local xnoremap = fss.xnoremap
local cnoremap = fss.cnoremap
local vnoremap = fss.vnoremap
local inoremap = fss.inoremap
local tnoremap = fss.tnoremap

-- Add Empty space above and below
nnoremap('[<space>', [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]])
nnoremap(']<space>', [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]])

-- Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap('Y', 'y$')

-- Capitalize
nnoremap('<leader>U', 'gUiw`]')
inoremap('<C-u>', '<cmd>norm!gUiw`]a<CR>')

-- Visual shifting (does not exit Visual mode)
vnoremap('<', '<gv')
vnoremap('>', '>gv')

--Remap back tick for jumping to marks more quickly back
nnoremap("'", '`')

nnoremap(
  '<localleader>l',
  [[<cmd>nohlsearch<cr><cmd>diffupdate<cr><cmd>syntax sync fromstart<cr><c-l>]]
)

-- Write and quit all files, ZZ is NOT equivalent to this
nnoremap('qa', '<cmd>qa<CR>')

-- find visually selected text
vnoremap('*', [[y/<C-R>"<CR>]])

-- make . work with visually selected lines
vnoremap('.', ':norm.<CR>')

-- Paste in visual mode multiple times
xnoremap('p', 'pgvy')

-- Conditionally modify character at end of line
nnoremap('<localleader>,', "<cmd>call utils#modify_line_end_delimiter(',')<cr>")
nnoremap('<localleader>;', "<cmd>call utils#modify_line_end_delimiter(';')<cr>")

------------------------------------------------------------------------------
-- Files
------------------------------------------------------------------------------

--open a new file in the same directory
nnoremap('<leader>nf', [[:e <C-R>=expand("%:p:h") . "/" <CR>]], { silent = false })

--open a new file in the same directory
nnoremap('<leader>ns', [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]], { silent = false })

-- Save
nnoremap('<c-s>', function()
  -- NOTE: this uses write specifically because we need to trigger a filesystem event
  -- even if the file isn't change so that things like hot reload work
  vim.cmd 'silent! write'
  vim.notify('Saved ' .. vim.fn.expand '%:t', nil, { timeout = 1000 })
end)

------------------------------------------------------------------------------
-- Folds
------------------------------------------------------------------------------

-- Evaluates whether there is a fold on the current line if so unfold it else return a normal space
nnoremap('<space><space>', [[@=(foldlevel('.')?'za':"\<Space>")<CR>]])

-- Refocus folds
nnoremap('<localleader>z', [[zMzvzz]])

-- Make zO recursively open whatever top level fold we're in, no matter where the
-- cursor happens to be.
nnoremap('zO', [[zCzO]])

-----------------------------------------------------------------------------//
-- Terminal {{{
------------------------------------------------------------------------------//

fss.augroup('AddTerminalMappings', {
  {
    events = { 'TermOpen' },
    targets = { 'term://*' },
    command = function()
      if vim.bo.filetype == '' or vim.bo.filetype == 'toggleterm' then
        local opts = { silent = false, buffer = 0 }
        tnoremap('<esc>', [[<C-\><C-n>]], opts)
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

--- }}}

----------------------------------------------------------------------------------
-- Windows {{{
----------------------------------------------------------------------------------

-- Change two horizontally split windows to vertical splits
nnoremap('<localleader>wh', '<C-W>t <C-W>K')

-- Change two vertically split windows to horizontal splits
nnoremap('<localleader>wv', '<C-W>t <C-W>H')

inoremap('<C-h>', '<C-w>h')
inoremap('<C-j>', '<C-w>j')
inoremap('<C-k>', '<C-w>k')
inoremap('<C-l>', '<C-w>l')

nnoremap('<C-h>', '<C-w>h')
nnoremap('<C-j>', '<C-w>j')
nnoremap('<C-k>', '<C-w>k')
nnoremap('<C-l>', '<C-w>l')

nnoremap('<C-Left>', '<C-w><')
-- nnoremap("<C-j>", "<C-w>j")
-- nnoremap("<C-k>", "<C-w>k")
nnoremap('<C-Right>', '<C-w>>')

--- }}}

------------------------------------------------------------------------------
-- Buffers {{{
------------------------------------------------------------------------------

-- Use wildmenu to cycle tabs
nnoremap('<localleader><tab>', [[:b <Tab>]], { silent = false })

-- Switch between the last two files
nnoremap('<leader><leader>', [[<c-^>]])

--- }}}

----------------------------------------------------------------------------------
-- Operators
----------------------------------------------------------------------------------

-- Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap('Y', 'y$')

------------------------------------------------------------------------------
-- Quickfix
------------------------------------------------------------------------------

nnoremap(']q', '<cmd>cnext<CR>zz')
nnoremap('[q', '<cmd>cprev<CR>zz')
nnoremap(']l', '<cmd>lnext<cr>zz')
nnoremap('[l', '<cmd>lprev<cr>zz')

------------------------------------------------------------------------------
-- Tab navigation
------------------------------------------------------------------------------

nnoremap('<leader>tn', '<cmd>tabedit %<CR>')
nnoremap('<leader>tc', '<cmd>tabclose<CR>')
nnoremap('<leader>to', '<cmd>tabonly<cr>')
nnoremap('<leader>tm', '<cmd>tabmove<Space>')
nnoremap(']t', '<cmd>tabprev<CR>')
nnoremap('[t', '<cmd>tabnext<CR>')

----------------------------------------------------------------------------//
-- Core navigation
----------------------------------------------------------------------------//

-- Store relative line number jumps in the jumplist.
nnoremap('j', [[(v:count > 1 ? 'm`' . v:count : '') . 'gj']], { expr = true, silent = true })
nnoremap('k', [[(v:count > 1 ? 'm`' . v:count : '') . 'gk']], { expr = true, silent = true })

-- Zero should go to the first non-blank character not to the first column (which could be blank)
nnoremap('0', '^')

-- when going to the end of the line in visual mode ignore whitespace characters
vnoremap('$', 'g_')

-- Toggle top/center/bottom
nmap(
  'zz',
  [[(winline() == (winheight (0) + 1)/ 2) ?  'zt' : (winline() == 1)? 'zb' : 'zz']],
  { expr = true }
)

-- Smooth scroll wheel
nmap('<ScrollWheelDown>', '<c-d>')
nmap('<ScrollWheelUp>', '<c-u>')

-- Arrows
nnoremap('<down>', '<nop>')
nnoremap('<up>', '<nop>')
nnoremap('<left>', '<nop>')
nnoremap('<right>', '<nop>')
inoremap('<up>', '<nop>')
inoremap('<down>', '<nop>')
inoremap('<left>', '<nop>')
inoremap('<right>', '<nop>')

----------------------------------------------------------------------------//
-- Nvim Configuration
----------------------------------------------------------------------------//

-- This line opens the vimrc in a vertical split
nnoremap('<leader>ev', [[:vsplit $MYVIMRC<cr>]])

nnoremap('<leader>ep', fmt('<Cmd>vsplit %s/lua/as/plugins/init.lua<CR>', fn.stdpath 'config'))

-- This line allows the current file to source the vimrc allowing me use bindings as they're added
nnoremap('<leader>sv', [[<Cmd>source $MYVIMRC<cr> <bar> :lua vim.notify('Sourced init.vim')<cr>]])

-----------------------------------------------------------------------------//
-- Quotes
-----------------------------------------------------------------------------//

nnoremap([[<leader>"]], [[ciw"<c-r>""<esc>]])
nnoremap('<leader>`', [[ciw`<c-r>"`<esc>]])
nnoremap("<leader>'", [[ciw'<c-r>"'<esc>]])
nnoremap('<leader>)', [[ciw(<c-r>")<esc>]])
nnoremap('<leader>}', [[ciw{<c-r>"}<esc>]])

-- Map Q to replay q register
nnoremap('Q', '@q')

-- 1. Position the cursor over a word; alternatively, make a selection.
-- 2. Hit cq to start recording the macro.
-- 3. Once you are done with the macro, go back to normal mode.
-- 4. Hit Enter to repeat the macro over search matches.
function fss.mappings.setup_CR()
  nmap('<Enter>', [[:nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]])
end

-- NOTE: this line is done as a vim command as handling the string in lua breaks
vim.cmd [[let g:mc = "y/\\V\<C-r>=escape(@\", '/')\<CR>\<CR>""]]
xnoremap('cn', [[g:mc . "``cgn"]], { expr = true, silent = true })
xnoremap('cN', [[g:mc . "``cgN"]], { expr = true, silent = true })
nnoremap('cq', [[:lua fss.mappings.setup_CR()<CR>*``qz]])
nnoremap('cQ', [[:lua fss.mappings.setup_CR()<CR>#``qz]])
xnoremap('cq', [[":\<C-u>lua fss.mappings.setup_CR()\<CR>" . "gv" . g:mc . "``qz"]], { expr = true })
xnoremap(
  'cQ',
  [[":\<C-u>lua fss.mappings.setup_CR()\<CR>" . "gv" . substitute(g:mc, '/', '?', 'g') . "``qz"]],
  { expr = true }
)

nnoremap('gf', '<Cmd>e <cfile><CR>')
-----------------------------------------------------------------------------//
-- Command mode
-----------------------------------------------------------------------------//
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

-- TODO: converting this to lua does not work for some obscure reason.
vim.cmd [[
  function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
  endfunction
]]

xnoremap('@', ':<C-u>call ExecuteMacroOverVisualRange()<CR>', { silent = false })

------------------------------------------------------------------------------
-- Google it / Feeling lucky
------------------------------------------------------------------------------

-- Credit: June Gunn <Leader>?/!
function fss.mappings.google(pat, lucky)
  local query = '"' .. fn.substitute(pat, '["\n]', ' ', 'g') .. '"'
  query = fn.substitute(query, '[[:punct:] ]', [[\=printf("%%%02X", char2nr(submatch(0)))]], 'g')
  fn.system(
    fn.printf(
      vim.g.open_command .. ' "https://www.google.com/search?%sq=%s"',
      lucky and 'btnI&' or '',
      query
    )
  )
end

nnoremap('<localleader>?', [[:lua fss.mappings.google(vim.fn.expand("<cWORD>"), false)<cr>]])
nnoremap('<localleader>!', [[:lua fss.mappings.google(vim.fn.expand("<cWORD>"), true)<cr>]])
xnoremap('<localleader>?', [["gy:lua fss.mappings.google(vim.api.nvim_eval("@g"), false)<cr>gv]])
xnoremap('<localleader>!', [["gy:lua fss.mappings.google(vim.api.nvim_eval("@g"), false, true)<cr>gv]])

-----------------------------------------------------------------------------//
-- Completion
-----------------------------------------------------------------------------//

-- cycle the completion menu with <TAB>
inoremap('<tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
inoremap('<s-tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })

-- nnoremap('<leader>g', [[:silent! set operatorfunc=v:lua.fss.mappings.grep_operator<cr>g@]])
-- xnoremap('<leader>g', [[:call v:lua.fss.mappings.grep_operator(visualmode())<cr>]])

---------------------------------------------------------------------------------
-- Toggle list
---------------------------------------------------------------------------------

local function toggle_list(prefix)
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    local location_list = fn.getloclist(0, { filewinid = 0 })
    local is_loc_list = location_list.filewinid > 0
    if vim.bo[buf].filetype == 'qf' or is_loc_list then
      fn.execute(prefix .. 'close')
      return
    end
  end
  if prefix == 'l' and vim.tbl_isempty(fn.getloclist(0)) then
    vim.notify('Location List is Empty.', 2)
    return
  end

  local winnr = fn.winnr()
  fn.execute(prefix .. 'open')
  if fn.winnr() ~= winnr then
    vim.cmd [[wincmd p]]
  end
end

nnoremap('<leader>ls', function()
  toggle_list 'c'
end)
nnoremap('<leader>li', function()
  toggle_list 'l'
end)

-----------------------------------------------------------------------------//
-- Commands
-----------------------------------------------------------------------------//

command {
  'ToggleBackground',
  function()
    vim.o.background = vim.o.background == 'dark' and 'light' or 'dark'
  end,
}

command { 'Todo', [[noautocmd silent! grep! 'TODO\|FIXME' | copen]] }

-- source https://superuser.com/a/540519
-- write the visual selection to the filename passed in as a command argument then delete the
-- selection placing into the black hole register
command {
  'MoveWrite',
  [[<line1>,<line2>write<bang> <args> | <line1>,<line2>delete _]],
  types = { '-bang', '-range', '-complete=file' },
  nargs = 1,
}
command {
  'MoveAppend',
  [[<line1>,<line2>write<bang> >> <args> | <line1>,<line2>delete _]],
  types = { '-bang', '-range', '-complete=file' },
  nargs = 1,
}

command { 'AutoResize', [[call utils#auto_resize(<args>)]], { '-nargs=?' } }

