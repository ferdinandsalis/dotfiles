local api = vim.api
local fmt = string.format
local P = fss.style.palette

local M = {}

---Convert a hex color to rgb
---@param color string
---@return number
---@return number
---@return number
local function hex_to_rgb(color)
  local hex = color:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5), 16)
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
function M.darken_color(color, percent)
  local r, g, b = hex_to_rgb(color)
  if not r or not g or not b then
    return "NONE"
  end
  r, g, b = alter(r, percent), alter(g, percent), alter(b, percent)
  r, g, b = math.min(r, 255), math.min(g, 255), math.min(b, 255)
  return string.format("#%02x%02x%02x", r, g, b)
end

--- Check if the current window has a winhighlight
--- which includes the specific target highlight
--- @param win_id integer
--- @vararg string
function M.has_win_highlight(win_id, ...)
  local win_hl = vim.wo[win_id].winhighlight
  local has_match = false
  for _, target in ipairs {...} do
    if win_hl:match(target) ~= nil then
      has_match = true
      break
    end
  end
  return (win_hl ~= nil and has_match), win_hl
end

---A mechanism to allow inheritance of the winhighlight of a specific
---group in a window
---@param win_id number
---@param target string
---@param name string
---@param default string
function M.adopt_winhighlight(win_id, target, name, default)
  name = name .. win_id
  local _, win_hl = M.has_win_highlight(win_id, target)
  local hl_exists = vim.fn.hlexists(name) > 0
  if not hl_exists then
    local parts = vim.split(win_hl, ",")
    local found =
      fss.find(
      parts,
      function(part)
        return part:match(target)
      end
    )
    if found then
      local hl_group = vim.split(found, ":")[2]
      local bg = M.get_hl(hl_group, "bg")
      local fg = M.get_hl(default, "fg")
      local gui = M.get_hl(default, "gui")
      M.set_hl(name, {guibg = bg, guifg = fg, gui = gui})
    end
  end
  return name
end

--- NOTE: vim.highlight's link and create are private, so
--- eventually move to using `nvim_set_hl`
---@param name string
---@param opts table
function M.set_hl(name, opts)
  assert(name and opts, "Both 'name' and 'opts' must be specified")
  if not vim.tbl_isempty(opts) then
    if opts.link then
      vim.highlight.link(name, opts.link, opts.force)
    else
      local ok, msg = pcall(vim.highlight.create, name, opts)
      if not ok then
        vim.notify(fmt("Failed to set %s because: %s", name, msg))
      end
    end
  end
end

---convert a table of gui values into a string
---@param hl table<string, string>
---@return string
local function flatten_gui(hl)
  local gui_attr = {"underline", "bold", "undercurl", "italic"}
  local gui = {}
  for name, value in pairs(hl) do
    if value and vim.tbl_contains(gui_attr, name) then
      table.insert(gui, name)
    end
  end
  return table.concat(gui, ",")
end

---Get the value a highlight group
---this function is a small wrapper around `nvim_get_hl_by_name`
---which handles errors, fallbacks as well as returning a gui value
---in the right format
---@param grp string
---@param attr string
---@param fallback string
---@return string
function M.get_hl(grp, attr, fallback)
  assert(grp, "Cannot get a highlight without specifying a group")
  local attrs = {fg = "foreground", bg = "background"}
  attr = attrs[attr] or attr
  local hl = api.nvim_get_hl_by_name(grp, true)
  if attr == "gui" then
    return flatten_gui(hl)
  end
  local color = hl[attr] or fallback
  -- convert the decimal rgba value from the hl by name to a 6 character hex + padding if needed
  if not color then
    vim.notify(fmt("%s %s does not exist", grp, attr))
    return "NONE"
  end
  -- convert the decimal rgba value from the hl by name to a 6 character hex + padding if needed
  return "#" .. bit.tohex(color, 6)
end

function M.clear_hl(name)
  if not name then
    return
  end
  vim.cmd(fmt("highlight clear %s", name))
end

---Apply a list of highlights
---@param hls table[]
function M.all(hls)
  for _, hl in ipairs(hls) do
    M.set_hl(unpack(hl))
  end
end

-----------------------------------------------------------------------------//
-- Color Scheme {{{1
-----------------------------------------------------------------------------//
vim.g.tokyonight_style = "storm"
vim.g.tokyonight_italic_functions = true
vim.g.tokyonight_sidebars = {"qf", "terminal", "packer"}
vim.cmd "colorscheme tokyonight"

---------------------------------------------------------------------------------
-- Plugin highlights
---------------------------------------------------------------------------------
local function plugin_highlights()
  local normal_bg = M.get_hl("Normal", "bg")
  local normal_fg = M.get_hl("Normal", "fg")
  local comment_fg = M.get_hl("Comment", "fg")
  local bg_color = M.darken_color(normal_bg, -10)
  local modal_border_color = comment_fg

  M.set_hl("TelescopePathSeparator", {link = "Directory"})
  M.set_hl("TelescopeQueryFilter", {link = "IncSearch"})
  M.set_hl("CompeDocumentation", {link = "Pmenu"})
  M.set_hl("BqfPreviewBorder", {guifg = modal_border_color})

  M.all(
    {
      -- whichkey.nvim
      {"WhichKeyFloating", {guibg = bg_color, force = true}},
      -- telescope.nvim
      {"TelescopePathSeparator", {link = "Directory"}},
      {"TelescopeQueryFilter", {link = "IncSearch"}},
      {"TelescopeResultsBorder", {guibg = normal_bg, guifg = modal_border_color}},
      {"TelescopePromptBorder", {guibg = normal_bg, guifg = modal_border_color}},
      {"TelescopePreviewBorder", {guibg = normal_bg, guifg = modal_border_color}},
      {"TelescopePreviewNormal", {guibg = normal_bg, guifg = normal_fg}},
      -- -- nvim-ts-rainbow
      {"rainbowcol1", {guifg = "#a3be8c"}},
      {"rainbowcol2", {guifg = "#99c2c1"}},
      {"rainbowcol3", {guifg = "#8fbcbb"}},
      {"rainbowcol4", {guifg = "#88c0d0"}},
      {"rainbowcol5", {guifg = "#81a1c1"}},
      {"rainbowcol6", {guifg = "#5e81ac"}},
      {"rainbowcol7", {guifg = "#4e6f97"}},
      -- bqf
      {"BqfPreviewBorder", {guifg = modal_border_color}}
    }
  )

  if plugin_loaded("conflict-marker.vim") then
    M.all {
      {"ConflictMarkerBegin", {guibg = "#2f7366"}},
      {"ConflictMarkerOurs", {guibg = "#2e5049"}},
      {"ConflictMarkerTheirs", {guibg = "#344f69"}},
      {"ConflictMarkerEnd", {guibg = "#2f628e"}},
      {"ConflictMarkerCommonAncestorsHunk", {guibg = "#754a81"}}
    }
  else
    -- Highlight VCS conflict markers
    vim.cmd [[match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$']]
  end
end
-- }}}

---------------------------------------------------------------------------------
-- General highlights
---------------------------------------------------------------------------------
local function general_overrides()
  local cursor_line_bg = M.get_hl("CursorLine", "bg")
  local normal_fg = M.get_hl("Normal", "fg")
  local bg_color = M.darken_color(M.get_hl("Normal", "bg"), -10)
  local comment_fg = M.get_hl("Comment", "fg")

  M.all(
    {
      {"CursorLineNr", {gui = "bold"}},
      {"ColorColumn", {guibg = cursor_line_bg}},
      {"Comment", {gui = "italic"}},
      {"Credit", {gui = "bold"}},
      {"NormalFloat", {link = "Normal"}},
      {"Error", {link = "WarningMsg", force = true}},
      {"ErrorMsg", {guibg = bg_color}},
      {"FoldColumn", {guibg = "background"}},
      {"Folded", {link = "Comment", force = true}},
      {"IncSearch", {guibg = "NONE", guifg = "#ff9e64", gui = "italic,bold,underline"}},
      {"Include", {gui = "italic"}},
      {"MsgArea", {guifg = normal_fg, guibg = bg_color}},
      {"MsgSeparator", {guifg = comment_fg, guibg = bg_color}},
      {"Type", {gui = "italic,bold"}},
      -- Treesitter
      {"TSKeyword", {link = "Statement"}},
      {"TSParameter", {gui = "italic,bold"}},
      -- LSP
      {"LspReferenceText", {gui = "underline"}},
      {"LspReferenceRead", {gui = "underline"}},
      -- Notifications
      {"NvimNotificationError", {link = "ErrorMsg"}},
      {"NvimNotificationInfo", {link = "Directory"}},
      -- Diff
      {"DiffAdd", {guibg = "#26332c", guifg = "NONE"}},
      {"DiffDelete", {guibg = "#572E33", guifg = "#5c6370", gui = "NONE"}},
      {"DiffChange", {guibg = "#273842", guifg = "NONE"}},
      {"DiffText", {guibg = "#314753", guifg = "NONE"}},
      {"diffAdded", {link = "DiffAdd", force = true}},
      {"diffChanged", {link = "DiffChange", force = true}},
      {"diffRemoved", {link = "DiffDelete", force = true}},
      {"diffBDiffer", {link = "WarningMsg", force = true}},
      {"diffCommon", {link = "WarningMsg", force = true}},
      {"diffDiffer", {link = "WarningMsg", force = true}},
      {"diffFile", {link = "Directory", force = true}},
      {"diffIdentical", {link = "WarningMsg", force = true}},
      {"diffIndexLine", {link = "Number", force = true}},
      {"diffIsA", {link = "WarningMsg", force = true}},
      {"diffNoEOL", {link = "WarningMsg", force = true}},
      {"diffOnly", {link = "WarningMsg", force = true}}
    }
  )
end

local function set_sidebar_highlight()
  local split_color = M.get_hl("VertSplit", "fg")
  local bg_color = M.darken_color(M.get_hl("Normal", "bg"), -10)
  local st_color = M.darken_color(M.get_hl("Normal", "bg"), -16)
  local hls = {
    {"PanelBackground", {guibg = bg_color}},
    {"PanelHeading", {guibg = bg_color, gui = "bold"}},
    {"PanelVertSplit", {guifg = split_color, guibg = bg_color}},
    {"PanelStNC", {guibg = st_color, cterm = "italic"}},
    {"PanelSt", {guibg = st_color}}
  }
  for _, grp in ipairs(hls) do
    M.set_hl(unpack(grp))
  end
end

local sidebar_fts = {"NvimTree"}

local function on_sidebar_enter()
  local highlights =
    table.concat(
    {
      "Normal:PanelBackground",
      "EndOfBuffer:PanelBackground",
      "StatusLine:PanelSt",
      "StatusLineNC:PanelStNC",
      "SignColumn:PanelBackground",
      "VertSplit:PanelVertSplit"
    },
    ","
  )
  vim.cmd("setlocal winhighlight=" .. highlights)
end

local function colorscheme_overrides()
  if vim.g.colors_name == "tokyonight" then
    local keyword_fg = M.get_hl("Keyword", "fg")
    local dark_bg = M.darken_color(M.get_hl("Normal", "bg"), -6)
    M.all {
      {"TSVariable", {guifg = "NONE"}},
      {"WhichKeyFloat", {link = "PanelBackground"}},
      {"Cursor", {guibg = keyword_fg, gui = "NONE"}},
      {"CursorLine", {guibg = dark_bg}},
      {"CursorLineNr", {guibg = dark_bg}},
      {"Pmenu", {guibg = dark_bg, blend = 6}}
    }
  end
end

local function user_highlights()
  plugin_highlights()
  general_overrides()
  colorscheme_overrides()
  set_sidebar_highlight()
end

---NOTE: apply user highlights when nvim first starts
--- then whenever the colorscheme changes
user_highlights()

fss.augroup(
  "UserHighlights",
  {
    {
      events = {"ColorScheme"},
      targets = {"*"},
      command = user_highlights
    },
    {
      events = {"FileType"},
      targets = sidebar_fts,
      command = on_sidebar_enter
    }
  }
)

return M
