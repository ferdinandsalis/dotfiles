----------------------------------------------------------------------------------
--  Whitespace highlighting
----------------------------------------------------------------------------------
--@source: https://vim.fandom.com/wiki/Highlight_unwanted_spaces (comment at the bottom)
--@implementation: https://github.com/inkarkat/vim-ShowTrailingWhitespace

local H = require 'fss.highlights'

local fn = vim.fn

local function is_floating_win()
  return vim.fn.win_gettype() == 'popup'
end

local function is_invalid_buf()
  return vim.bo.filetype == '' or vim.bo.buftype ~= '' or not vim.bo.modifiable
end

local function toggle_trailing(mode)
  if is_invalid_buf() or is_floating_win() then
    vim.wo.list = false
    return
  end
  if not vim.wo.list then
    vim.wo.list = true
  end
  local pattern = mode == 'i' and [[\s\+\%#\@<!$]] or [[\s\+$]]
  if vim.w.whitespace_match_number then
    fn.matchdelete(vim.w.whitespace_match_number)
    fn.matchadd('ExtraWhitespace', pattern, 10, vim.w.whitespace_match_number)
  else
    vim.w.whitespace_match_number = fn.matchadd('ExtraWhitespace', pattern)
  end
end

H.set_hl('ExtraWhitespace', { foreground = 'red' })

fss.augroup('WhitespaceMatch', {
  {
    event = 'ColorScheme',
    pattern = { '*' },
    command = function()
      H.set_hl('ExtraWhitespace', { foreground = 'red' })
    end,
  },
  {
    event = { 'BufEnter', 'FileType', 'InsertLeave' },
    pattern = { '*' },
    command = function()
      toggle_trailing 'n'
    end,
  },
  {
    event = 'InsertEnter',
    pattern = { '*' },
    command = function()
      toggle_trailing 'i'
    end,
  },
})
