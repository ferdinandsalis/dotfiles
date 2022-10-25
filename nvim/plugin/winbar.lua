---@diagnostic disable: duplicate-doc-param

if not fss or not fss.ui.winbar.enable then
  return
end

local highlights = require('fss.highlights')
local utils = require('fss.utils.statusline')

local fn, api = vim.fn, vim.api
local component = utils.component
local component_raw = utils.component_raw
local empty = fss.empty
local icons = fss.style.icons.misc
local contains = vim.tbl_contains

local dir_separator = '/'
local separator = icons.arrow_right
local ellipsis = icons.ellipsis

--- A mapping of each winbar items ID to its path
--- @type table<string, string>
fss.ui.winbar.state = {}

---@param id number
---@param _ number number of clicks
---@param _ "l"|"r"|"m" the button clicked
---@param _ string modifiers
function fss.ui.winbar.click(id, _, _, _)
  if id then
    vim.cmd.edit(fss.ui.winbar.state[id])
  end
end

highlights.plugin('winbar', {
  { Winbar = { bold = false } },
  { WinbarNC = { bold = false } },
  { WinbarCrumb = { bold = true } },
  { WinbarIcon = { inherit = 'Function' } },
  { WinbarDirectory = { inherit = 'Directory' } },
})

local function breadcrumbs()
  local ok, navic = pcall(require, 'nvim-navic')
  local empty_state = { component(ellipsis, 'NonText', { priority = 0 }) }
  if not ok or not navic.is_available() then
    return empty_state
  end
  local navic_ok, location = pcall(navic.get_location)
  if not navic_ok or empty(location) then
    return empty_state
  end
  local win = api.nvim_get_current_win()
  return {
    component_raw(location, { priority = 1, win_id = win, type = 'winbar' }),
  }
end

---@return string
function fss.ui.winbar.get()
  local winbar = {}
  local add = utils.winline(winbar)

  add(utils.spacer(1))

  local bufname = api.nvim_buf_get_name(api.nvim_get_current_buf())
  if empty(bufname) then
    return add(component('[No name]', 'Winbar', { priority = 0 }))
  end

  local parts = vim.split(fn.fnamemodify(bufname, ':.'), '/')

  fss.foreach(function(part, index)
    local priority = (#parts - (index - 1)) * 2
    local is_last = index == #parts
    local sep = is_last and separator or dir_separator
    local hl = is_last and 'Winbar' or 'NonText'
    local suffix_hl = is_last and 'WinbarDirectory' or 'NonText'
    fss.ui.winbar.state[priority] = table.concat(
      vim.list_slice(parts, 1, index),
      '/'
    )
    add(component(part, hl, {
      id = priority,
      priority = priority,
      click = 'v:lua.fss.ui.winbar.click',
      suffix = sep,
      suffix_color = suffix_hl,
    }))
  end, parts)
  add(unpack(breadcrumbs()))
  return utils.display(
    winbar,
    api.nvim_win_get_width(api.nvim_get_current_win())
  )
end

local blocked_fts = {
  'NeogitStatus',
  'DiffviewFiles',
  'NeogitCommitMessage',
  'toggleterm',
  'DressingInput',
  'org',
}

local allowed_fts = { 'toggleterm', 'neo-tree' }
local allowed_buftypes = { 'terminal' }

local function set_winbar()
  fss.foreach(function(w)
    local buf, win = vim.bo[api.nvim_win_get_buf(w)], vim.wo[w]
    local bt, ft, is_diff = buf.buftype, buf.filetype, win.diff
    local ignored = contains(allowed_fts, ft) or contains(allowed_buftypes, bt)
    if not ignored then
      if
        not contains(blocked_fts, ft)
        and fn.win_gettype(api.nvim_win_get_number(w)) == ''
        and bt == ''
        and ft ~= ''
        and not is_diff
      then
        win.winbar = '%{%v:lua.fss.ui.winbar.get()%}'
      elseif is_diff then
        win.winbar = nil
      end
    end
  end, api.nvim_tabpage_list_wins(0))
end

fss.augroup('AttachWinbar', {
  {
    event = { 'BufWinEnter', 'TabNew', 'TabEnter', 'BufEnter', 'WinClosed' },
    desc = 'Toggle winbar',
    command = set_winbar,
  },
  {
    event = 'User',
    pattern = { 'DiffviewDiffBufRead', 'DiffviewDiffBufWinEnter' },
    desc = 'Toggle winbar',
    command = set_winbar,
  },
})
