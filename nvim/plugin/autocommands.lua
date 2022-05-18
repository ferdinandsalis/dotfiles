local fn = vim.fn
local api = vim.api
local fmt = string.format
local contains = vim.tbl_contains
local map = vim.keymap.set

----------------------------------------------------------------------------------------------------
-- HLSEARCH
----------------------------------------------------------------------------------------------------
map({ 'n', 'v', 'o', 'i', 'c' }, '<Plug>(StopHL)', 'execute("nohlsearch")[-1]', { expr = true })

local function stop_hl()
  if vim.v.hlsearch == 0 or api.nvim_get_mode().mode ~= 'n' then
    return
  end
  api.nvim_feedkeys(fss.replace_termcodes('<Plug>(StopHL)'), 'm', false)
end

local function hl_search()
  local col = api.nvim_win_get_cursor(0)[2]
  local curr_line = api.nvim_get_current_line()
  local ok, match = pcall(fn.matchstrpos, curr_line, fn.getreg('/'), 0)
  if not ok then
    return vim.notify(match, 'error', { title = 'HL SEARCH' })
  end
  local _, p_start, p_end = unpack(match)
  -- if the cursor is in a search result, leave highlighting on
  if col < p_start or col > p_end then
    stop_hl()
  end
end

fss.augroup('VimrcIncSearchHighlight', {
  {
    -- automatically clear search highlight once leaving the commandline
    event = { 'CursorMoved' },
    command = function()
      hl_search()
    end,
  },
  {
    event = { 'InsertEnter' },
    command = function()
      stop_hl()
    end,
  },
  {
    event = { 'OptionSet' },
    pattern = { 'hlsearch' },
    command = function()
      vim.schedule(function()
        vim.cmd('redrawstatus')
      end)
    end,
  },
})

local smart_close_filetypes = {
  'help',
  'git-status',
  'git-log',
  'gitcommit',
  'dbui',
  'LuaTree',
  'log',
  'tsplayground',
  'qf',
}

local smart_close_buftypes = {}

local function smart_close()
  if fn.winnr('$') ~= 1 then
    api.nvim_win_close(0, true)
  end
end

fss.augroup('SmartClose', {
  {
    -- Auto open grep quickfix window
    event = 'QuickFixCmdPost',
    pattern = { '*grep*' },
    command = 'cwindow',
  },
  {
    -- Close certain filetypes by pressing q.
    event = 'FileType',
    pattern = { '*' },
    command = function()
      local is_readonly = (vim.bo.readonly or not vim.bo.modifiable) and fn.hasmapto('q', 'n') == 0

      local is_eligible = vim.bo.buftype ~= ''
        or is_readonly
        or vim.wo.previewwindow
        or contains(smart_close_buftypes, vim.bo.buftype)
        or contains(smart_close_filetypes, vim.bo.filetype)

      if is_eligible then
        fss.nnoremap('q', smart_close, { buffer = 0, nowait = true })
      end
    end,
  },
  {
    -- Close quick fix window if the file containing it was closed
    event = 'BufEnter',
    pattern = { '*' },
    command = function()
      if fn.winnr('$') == 1 and vim.bo.buftype == 'quickfix' then
        api.nvim_buf_delete(0, { force = true })
      end
    end,
  },
  {
    -- automatically close corresponding loclist when quitting a window
    event = 'QuitPre',
    pattern = { '*' },
    nested = true,
    command = function()
      if vim.bo.filetype ~= 'qf' then
        vim.cmd('silent! lclose')
      end
    end,
  },
})

fss.augroup('ExternalCommands', {
  {
    -- Open images in an image viewer (probably Preview)
    event = 'BufEnter',
    pattern = { '*.png', '*.jpg', '*.gif' },
    command = function()
      vim.cmd(fmt('silent! "%s | :bw"', vim.g.open_command .. ' ' .. fn.expand('%')))
    end,
  },
})

fss.augroup('CheckOutsideTime', {
  {
    -- automatically check for changed files outside vim
    event = {
      'WinEnter',
      'BufWinEnter',
      'BufWinLeave',
      'BufRead',
      'BufEnter',
      'FocusGained',
    },
    pattern = { '*' },
    command = 'silent! checktime',
  },
})

-- See :h skeleton
fss.augroup('Templates', {
  {
    event = 'BufNewFile',
    pattern = { '*.sh' },
    command = '0r $DOTFILES/.config/nvim/templates/skeleton.sh',
  },
  {
    event = 'BufNewFile',
    pattern = { '*.lua' },
    command = '0r $DOTFILES/.config/nvim/templates/skeleton.lua',
  },
})

--- automatically clear commandline messages after a few seconds delay
--- source: http://unix.stackexchange.com/a/613645
---@return function
local function clear_commandline()
  --- Track the timer object and stop any previous timers before setting
  --- a new one so that each change waits for 10secs and that 10secs is
  --- deferred each time
  local timer
  return function()
    if timer then
      timer:stop()
    end
    timer = vim.defer_fn(function()
      if fn.mode() == 'n' then
        vim.cmd([[echon '']])
      end
    end, 10000)
  end
end

fss.augroup('ClearCommandMessages', {
  {
    event = { 'CmdlineLeave', 'CmdlineChanged' },
    pattern = { ':' },
    command = function()
      clear_commandline()
    end,
  },
})

if vim.env.TMUX ~= nil then
  fss.augroup('External', {
    -- {
    --   event = 'BufEnter',
    --   pattern = { '*' },
    --   command = function()
    --     vim.o.titlestring = require('fss.external').title_string()
    --   end,
    -- },
    {
      event = 'VimLeavePre',
      pattern = { '*' },
      command = function()
        require('fss.external').tmux.set_statusline(true)
      end,
    },
    {
      event = { 'ColorScheme', 'FocusGained' },
      pattern = { '*' },
      command = function()
        -- NOTE: there is a race condition here as the colors
        -- for kitty to re-use need to be set AFTER the rest of the colorscheme
        -- overrides
        vim.defer_fn(function()
          require('fss.external').tmux.set_statusline()
        end, 1)
      end,
    },
  })
end

fss.augroup('TextYankHighlight', {
  {
    -- don't execute silently in case of errors
    event = 'TextYankPost',
    pattern = { '*' },
    command = function()
      vim.highlight.on_yank({
        timeout = 500,
        on_visual = false,
        higroup = 'Visual',
      })
    end,
  },
})

local column_exclude = { 'gitcommit' }
local column_clear = {
  'startify',
  'vimwiki',
  'vim-plug',
  'help',
  'fugitive',
  'mail',
  'org',
  'orgagenda',
  'NeogitStatus',
  'norg',
}

--- Set or unset the color column depending on the filetype of the buffer and its eligibility
---@param leaving boolean indicates if the function was called on window leave
local function check_color_column(leaving)
  if contains(column_exclude, vim.bo.filetype) then
    return
  end

  local not_eligible = not vim.bo.modifiable
    or vim.wo.previewwindow
    or vim.bo.buftype ~= ''
    or not vim.bo.buflisted

  local small_window = api.nvim_win_get_width(0) <= vim.bo.textwidth + 1
  local is_last_win = #api.nvim_list_wins() == 1

  if
    contains(column_clear, vim.bo.filetype)
    or not_eligible
    or (leaving and not is_last_win)
    or small_window
  then
    vim.wo.colorcolumn = ''
    return
  end
  if vim.wo.colorcolumn == '' then
    vim.wo.colorcolumn = '+1'
  end
end

fss.augroup('CustomColorColumn', {
  {
    -- Update the cursor column to match current window size
    event = { 'WinEnter', 'BufEnter', 'VimResized', 'FileType' },
    pattern = { '*' },
    command = function()
      check_color_column()
    end,
  },
  {
    event = 'WinLeave',
    pattern = { '*' },
    command = function()
      check_color_column(true)
    end,
  },
})
fss.augroup('UpdateVim', {
  {
    -- TODO: not clear what effect this has in the post vimscript world
    -- it correctly sources $MYVIMRC but all the other files that it
    -- requires will need to be resourced or reloaded themselves
    event = 'BufWritePost',
    pattern = { '$DOTFILES/**/nvim/plugin/*.{lua,vim}', fn.expand('$MYVIMRC') },
    nested = true,
    command = function()
      local ok, msg = pcall(vim.cmd, 'source $MYVIMRC | redraw | silent doautocmd ColorScheme')
      msg = ok and 'sourced ' .. vim.fn.fnamemodify(vim.env.MYVIMRC, ':t') or msg
      vim.notify(msg)
    end,
  },
  {
    event = 'FocusLost',
    pattern = { '*' },
    command = 'silent! wall',
  },
  -- Make windows equal size when vim resizes
  {
    event = 'VimResized',
    pattern = { '*' },
    command = 'wincmd =',
  },
})

fss.augroup('WindowBehaviours', {
  {
    -- map q to close command window on quit
    event = 'CmdwinEnter',
    pattern = { '*' },
    command = 'nnoremap <silent><buffer><nowait> q <C-W>c',
  },
  -- Automatically jump into the quickfix window on open
  {
    event = 'QuickFixCmdPost',
    pattern = { '[^l]*' },
    nested = true,
    command = 'cwindow',
  },
  {
    event = 'QuickFixCmdPost',
    pattern = { 'l*' },
    nested = true,
    command = 'lwindow',
  },
})

local function should_show_cursorline()
  return vim.bo.buftype ~= 'terminal'
    and not vim.wo.previewwindow
    and vim.wo.winhighlight == ''
    and vim.bo.filetype ~= ''
end

fss.augroup('Cursorline', {
  {
    event = 'BufEnter',
    pattern = { '*' },
    command = function()
      if should_show_cursorline() then
        vim.wo.cursorline = true
      end
    end,
  },
  {
    event = 'BufLeave',
    pattern = { '*' },
    command = function()
      vim.wo.cursorline = false
    end,
  },
})

local save_excluded = { 'lua.luapad', 'gitcommit', 'NeogitCommitMessage' }
local function can_save()
  return fss.empty(vim.bo.buftype)
    and not fss.empty(vim.bo.filetype)
    and vim.bo.modifiable
    and not vim.tbl_contains(save_excluded, vim.bo.filetype)
end

fss.augroup('Utilities', {
  {
    -- @source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
    event = 'BufReadCmd',
    pattern = { 'file:///*' },
    command = function()
      vim.cmd(fmt('bd!|edit %s', vim.uri_from_fname('<afile>')))
    end,
  },
  {
    -- When editing a file, always jump to the last known cursor position.
    -- Don't do it for commit messages, when the position is invalid.
    event = { 'BufReadPost' },
    command = function()
      if vim.bo.ft ~= 'gitcommit' and vim.fn.win_gettype() ~= 'popup' then
        if fn.line([['"]]) > 0 and fn.line([['"]]) <= fn.line('$') then
          -- Check if the last line of the buffer is the same as the window
          if fn.line('w$') == fn.line('$') then
            -- Set line to last line edited
            vim.cmd([[normal! g`"]])
            -- Try to center
          elseif fn.line('$') - fn.line([['"]]) > ((fn.line('w$') - fn.line('w0')) / 2) - 1 then
            vim.cmd([[normal! g`"zz]])
          else
            vim.cmd([[normal! G'"<c-e>]])
          end
        end
      end
    end,
  },
  {
    event = 'FileType',
    pattern = { 'gitcommit', 'gitrebase' },
    command = 'set bufhidden=delete',
  },
  {
    event = { 'BufWritePre', 'FileWritePre' },
    pattern = { '*' },
    command = "silent! call mkdir(expand('<afile>:p:h'), 'p')",
  },
  {
    event = 'BufLeave',
    pattern = { '*' },
    command = function()
      if can_save() then
        vim.cmd('silent! update')
      end
    end,
  },
  {
    event = 'BufWritePost',
    pattern = { '*' },
    nested = true,
    command = function()
      if fss.empty(vim.bo.filetype) or fn.exists('b:ftdetect') == 1 then
        vim.cmd([[
            unlet! b:ftdetect
            filetype detect
            echom 'Filetype set to ' . &ft
          ]])
      end
    end,
  },
})

fss.augroup('TerminalAutocommands', {
  {
    event = 'TermClose',
    pattern = { '*' },
    command = function()
      --- automatically close a terminal if the job was successful
      if not vim.v.event.status == 0 then
        vim.cmd('bdelete! ' .. fn.expand('<abuf>'))
      end
    end,
  },
})
