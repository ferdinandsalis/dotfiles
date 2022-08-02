local fmt = string.format
local fn = vim.fn
local api = vim.api
local levels = vim.log.levels

local M = {}

---@class HLAttrs
---@field from string
---@field attr 'foreground' | 'fg' | 'background' | 'bg'

---Convert a hex color to RGB
---@param color string
---@return number
---@return number
---@return number
local function hex_to_rgb(color)
  local hex = color:gsub('#', '')
  return tonumber(hex:sub(1, 2), 16),
    tonumber(hex:sub(3, 4), 16),
    tonumber(hex:sub(5), 16)
end

local function alter(attr, percent)
  return math.floor(attr * (100 + percent) / 100)
end

---@source https://stackoverflow.com/q/5560248
---@see: https://stackoverflow.com/a/37797380
---Darken a specified hex color
---@param color string
---@param percent number
---@return string
function M.alter_color(color, percent)
  local r, g, b = hex_to_rgb(color)
  if not r or not g or not b then
    return 'NONE'
  end
  r, g, b = alter(r, percent), alter(g, percent), alter(b, percent)
  r, g, b = math.min(r, 255), math.min(g, 255), math.min(b, 255)
  return fmt('#%02x%02x%02x', r, g, b)
end

--- Check if the current window has a winhighlight
--- which includes the specific target highlight
--- @param win_id integer
--- @vararg string
--- @return boolean, string
function M.winhighlight_exists(win_id, ...)
  local win_hl = vim.wo[win_id].winhighlight
  for _, target in ipairs({ ... }) do
    if win_hl:match(target) ~= nil then
      return true, win_hl
    end
  end
  return false, win_hl
end

---@param group_name string A highlight group name
local function get_hl(group_name)
  local ok, hl = pcall(api.nvim_get_hl_by_name, group_name, true)
  if ok then
    hl.foreground = hl.foreground and '#' .. bit.tohex(hl.foreground, 6)
    hl.background = hl.background and '#' .. bit.tohex(hl.background, 6)
    hl[true] = nil -- BUG: API returns a true key which errors during the merge
    return hl
  end
  return {}
end

---A mechanism to allow inheritance of the winhighlight of a specific
---group in a window
---@param win_id number
---@param target string
---@param name string
---@param fallback string
function M.adopt_winhighlight(win_id, target, name, fallback)
  local win_hl_name = name .. win_id
  local _, win_hl = M.winhighlight_exists(win_id, target)
  local hl_exists = fn.hlexists(win_hl_name) > 0
  if hl_exists then
    return win_hl_name
  end
  local parts = vim.split(win_hl, ',')
  local found = fss.find(parts, function(part)
    return part:match(target)
  end)
  if not found then
    return fallback
  end
  local hl_group = vim.split(found, ':')[2]
  local bg = M.get(hl_group, 'bg')
  M.set(win_hl_name, { background = bg, inherit = fallback })
  return win_hl_name
end

--- Sets a neovim highlight with some syntactic sugar. It takes a highlight table and converts
--- any highlights specified as `GroupName = { from = 'group'}` into the underlying colour
--- by querying the highlight property of the from group so it can be used when specifying highlights
--- as a shorthand to derive the right color.
--- For example:
--- ```lua
---   M.set({ MatchParen = {foreground = {from = 'ErrorMsg'}}})
--- ```
--- This will take the foreground colour from ErrorMsg and set it to the foreground of MatchParen.
---@param name string
---@param opts table<string, string|boolean|HLAttrs>
function M.set(name, opts)
  assert(name and opts, "Both 'name' and 'opts' must be specified")
  assert(
    type(name) == 'string',
    fmt("Name must be a string but got '%s'", name)
  )
  assert(
    type(opts) == 'table',
    fmt("Opts must be a table but got '%s'", vim.inspect(opts))
  )

  local hl = get_hl(opts.inherit or name)
  opts.inherit = nil

  for attr, value in pairs(opts) do
    if type(value) == 'table' and value.from then
      opts[attr] = M.get(value.from, vim.F.if_nil(value.attr, attr))
      if value.alter then
        opts[attr] = M.alter_color(opts[attr], value.alter)
      end
    end
  end

  local ok, msg = pcall(
    api.nvim_set_hl,
    0,
    name,
    vim.tbl_deep_extend('force', hl, opts)
  )
  if not ok then
    vim.notify(fmt('Failed to set %s because - %s', name, msg))
  end
end

---Get the value a highlight group whilst handling errors, fallbacks as well as returning a gui value
---If no attribute is specified return the entire highlight table
---in the right format
---@param group string
---@param attribute string?
---@param fallback string?
---@return string
function M.get(group, attribute, fallback)
  if not group then
    vim.notify(
      'Cannot get a highlight without specifying a group',
      levels.ERROR
    )
    return 'NONE'
  end
  local hl = get_hl(group)
  if not attribute then
    return hl
  end
  attribute = ({ fg = 'foreground', bg = 'background' })[attribute] or attribute
  local color = hl[attribute] or fallback
  if not color then
    vim.schedule(function()
      vim.notify(fmt('%s %s does not exist', group, attribute), levels.INFO)
    end)
    return 'NONE'
  end
  -- convert the decimal RGBA value from the hl by name to a 6 character hex + padding if needed
  return color
end

function M.clear_hl(name)
  assert(name, 'name is required to clear a highlight')
  api.nvim_set_hl(0, name, {})
end

---Apply a list of highlights
---@param hls table<string, table<string, boolean|string>>
function M.all(hls)
  fss.foreach(function(hl)
    M.set(next(hl))
  end, hls)
end

-- Plugin highlights

---Apply highlights for a plugin and refresh on colorscheme change
---@param name string plugin name
---@param hls table<string, table> map of highlights
function M.plugin(name, hls)
  name = name:gsub('^%l', string.upper) -- capitalise the name for autocommand convention sake
  M.all(hls)
  fss.augroup(fmt('%sHighlightOverrides', name), {
    {
      event = 'ColorScheme',
      command = function()
        -- Defer resetting these highlights to ensure they apply after other overrides
        vim.defer_fn(function()
          M.all(hls)
        end, 1)
      end,
    },
  })
end

-- Highlights

local function general_overrides()
  local normal_bg = M.get('Normal', 'bg')
  local dim = M.alter_color(normal_bg, 20)

  M.all({
    { Dim = { foreground = dim } },
    { VertSplit = { background = 'NONE', foreground = dim } },
    { WinSeparator = { background = 'NONE', foreground = dim } },
    { CursorLineNr = { inherit = 'CursorLine', bold = true } },
    { FoldColumn = { background = 'background' } },
    { LspCodeLens = { inherit = 'Comment', bold = true, italic = false } },

    -- Floats
    { NormalFloat = {
      bg = { from = 'Normal', alter = -8 },
    } },
    {
      FloatBorder = {
        bg = { from = 'Normal', alter = -8 },
        fg = { from = 'Comment', alter = 8 },
      },
    },

    { Comment = { italic = true } },
    { Type = { italic = true, bold = true } },
    { Include = { italic = true, bold = false } },
    {
      QuickFixLine = {
        inherit = 'PmenuSbar',
        foreground = 'NONE',
        italic = true,
      },
    },
    { SignColumn = { background = 'NONE' } },
    { EndOfBuffer = { background = 'NONE' } },
  })
end

local function colorscheme_overrides()
  if vim.g.colors_name == 'everforest' then
    local palette = fss.style.palette

    M.all({
      { URL = { foreground = palette.blue } },
      { MsgArea = { background = { from = 'Normal', alter = -10 } } },
      { MsgSeparator = { link = 'MsgArea' } },
      { StatusLine = { background = { from = 'Normal', alter = 16 } } },
      { CursorLine = { background = { from = 'Normal', alter = 8 } } },
      { CursorLineNr = { foreground = palette.white } },
      { WhichkeyFloat = { link = 'NormalFloat' } },
      { ScrollView = { link = 'PMenu' } },
      { ColorColumn = { link = 'CursorLine' } },
    })
  end
end

local function set_sidebar_highlight()
  local normal_bg = M.get('Normal', 'bg')
  local split_color = M.get('VertSplit', 'fg')
  local bg_color = M.alter_color(normal_bg, -10)
  local dark_bg_color = M.alter_color(normal_bg, -14)
  M.all({
    { PanelBackground = { background = bg_color } },
    { PanelDarkBackground = { background = dark_bg_color } },
    {
      PanelHeading = { background = M.get('StatusLine', 'bg'), bold = true },
    },
    { PanelVertSplit = { foreground = split_color, background = bg_color } },
    {
      PanelWinSeparator = { foreground = split_color, background = bg_color },
    },
    { PanelStNC = { background = normal_bg, foreground = split_color } },
    { PanelSt = { background = M.get('StatusLine', 'bg') } },
  })
end

local sidebar_fts = {
  'packer',
  'flutterToolsOutline',
  'undotree',
  'Outline',
  'dbui',
  'neotest-summary',
  'pr',
}

local function on_sidebar_enter()
  vim.wo.winhighlight = table.concat({
    'Normal:PanelBackground',
    'EndOfBuffer:PanelBackground',
    'StatusLine:PanelSt',
    'StatusLineNC:PanelStNC',
    'SignColumn:PanelBackground',
    'VertSplit:PanelVertSplit',
    'WinSeparator:PanelWinSeparator',
  }, ',')
end

local function user_highlights()
  general_overrides()
  set_sidebar_highlight()
  colorscheme_overrides()
end

fss.augroup('UserHighlights', {
  {
    event = 'ColorScheme',
    command = function()
      user_highlights()
    end,
  },
  {
    event = 'FileType',
    pattern = sidebar_fts,
    command = function()
      on_sidebar_enter()
    end,
  },
})

-- Color Scheme {{{1

-- -- Tokyonight
-- if fss.plugin_installed('tokyonight.nvim') then
--   vim.g.tokyonight_transparent = false
--   vim.g.tokyonight_style = 'night' -- "storm" | "day"
--   vim.g.tokyonight_sidebars = { 'neo-tree', 'qf', 'terminal', 'packer' }
--   vim.g.tokyonight_dark_sidebar = true
--   local ok, msg = pcall(vim.cmd.colorscheme, 'tokyonight')
--   if not ok then
--     vim.notify(fmt('Theme failed to load because: %s', msg), 'error')
--   end
-- end

-- Everforest
if fss.plugin_installed('everforest') then
  vim.g.everforest_background = 'hard' -- "hard" | "medium" | "soft"
  vim.g.everforest_better_performance = true
  vim.g.everforest_cursor = 'auto'
  vim.g.everforest_enable_italic = true
  vim.g.everforest_transparent_background = false
  local ok, msg = pcall(vim.cmd.colorscheme, 'everforest')
  if not ok then
    vim.notify(fmt('Theme failed to load because: %s', msg), 'error')
  end
end

-- Nightfox
-- if fss.plugin_installed('nightfox.nvim') then
--   local ok, msg = pcall(vim.cmd.colorscheme, 'nightfox')
--   if not ok then
--     vim.notify(fmt('Theme failed to load because: %s', msg), 'error')
--   end
-- end

-- }}}

return M

-- vim:foldmethod=marker
