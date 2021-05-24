local fn = vim.fn
local api = vim.api
local fmt = string.format

local M = {}

local ts_playground_loaded, ts_hl_info

-----------------------------------------------------------------------------
-- Color Scheme {{{1

vim.g.tokyonight_style = "storm"
vim.g.tokyonight_italic_functions = true
vim.g.tokyonight_sidebars = {"qf", "terminal", "packer"}

local ok, msg = pcall(vim.cmd, "colorscheme tokyonight")
if not ok then
  fss.echomsg(msg)
end

-- }}}

-----------------------------------------------------------------------------//
-- CREDIT: @Cocophon
-- This function allows you to see the syntax highlight token of the cursor word and that token's links
---> https://github.com/cocopon/pgmnt.vim/blob/master/autoload/pgmnt/dev.vim
-----------------------------------------------------------------------------//
local function hi_chain(syn_id)
  local name = fn.synIDattr(syn_id, "name")
  local names = {}
  table.insert(names, name)
  local original = fn.synIDtrans(syn_id)
  if syn_id ~= original then
    table.insert(names, fn.synIDattr(original, "name"))
  end

  return names
end

function M.token_inspect()
  if not ts_playground_loaded then
    ts_playground_loaded, ts_hl_info = pcall(require, "nvim-treesitter-playground.hl-info")
  end
  if vim.tbl_contains(fss.ts.get_filetypes(), vim.bo.filetype) then
    ts_hl_info.show_hl_captures()
  else
    local syn_id = fn.synID(fn.line("."), fn.col("."), 1)
    local names = hi_chain(syn_id)
    fss.echomsg(fn.join(names, " -> "))
  end
end

--- Check if the current window has a winhighlight
--- which includes the specific target highlight
--- @param win_id integer
--- @vararg string
function M.has_win_highlight(win_id, ...)
  local win_hl = vim.wo[win_id].winhighlight
  local has_match = false
  for _, target in ipairs({...}) do
    if win_hl:match(target) ~= nil then
      has_match = true
      break
    end
  end
  return (win_hl ~= nil and has_match), win_hl
end

local function find(haystack, matcher)
  local found
  for _, needle in ipairs(haystack) do
    if matcher(needle) then
      found = needle
      break
    end
  end
  return found
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
      find(
      parts,
      function(part)
        return part:match(target)
      end
    )
    if found then
      local hl_group = vim.split(found, ":")[2]
      local bg = M.hl_value(hl_group, "bg")
      local fg = M.hl_value(default, "fg")
      local gui = M.hl_value(default, "gui")
      M.highlight(name, {guibg = bg, guifg = fg, gui = gui})
    end
  end
  return name
end

--- TODO eventually move to using `nvim_set_hl`
--- however for the time being that expects colors
--- to be specified as rgb not hex
---@param name string
---@param opts table
function M.highlight(name, opts)
  local keys = {
    gui = true,
    guifg = true,
    guibg = true,
    guisp = true,
    cterm = true,
    blend = true
  }
  local force = opts.force or false
  if name and not vim.tbl_isempty(opts) then
    if opts.link and opts.link ~= "" then
      vim.cmd("highlight" .. (force and "!" or "") .. " link " .. name .. " " .. opts.link)
    else
      local cmd = {"highlight", name}
      for k, v in pairs(opts) do
        if keys[k] and keys[k] ~= "" then
          table.insert(cmd, fmt("%s=", k) .. v)
        end
      end
      vim.cmd(table.concat(cmd, " "))
    end
  end
end

local gui_attr = {"underline", "bold", "undercurl", "italic"}
local attrs = {fg = "foreground", bg = "background"}

function M.hl_value(grp, attr)
  attr = attrs[attr] or attr
  local hl = api.nvim_get_hl_by_name(grp, true)
  if attr == "gui" then
    local gui = {}
    for name, value in pairs(hl) do
      if value and vim.tbl_contains(gui_attr, name) then
        table.insert(gui, name)
      end
    end
    return table.concat(gui, ",")
  end
  local color = hl[attr]
  -- convert the decimal rgba value from the hl by name to a 6 character hex + padding if needed
  return "#" .. bit.tohex(color, 6)
end

function M.all(hls)
  for _, hl in ipairs(hls) do
    M.highlight(unpack(hl))
  end
end

---------------------------------------------------------------------------------
-- Plugin highlights {{{
---------------------------------------------------------------------------------
local function plugin_highlights()
  local normal_bg = M.hl_value("Normal", "bg")
  local normal_fg = M.hl_value("Normal", "fg")
  local comment_fg = M.hl_value("Comment", "fg")
  local bg_color = M.darken_color(normal_bg, -10)
  local modal_border_color = comment_fg

  M.highlight("TelescopePathSeparator", {link = "Directory"})
  M.highlight("TelescopeQueryFilter", {link = "IncSearch"})
  M.highlight("CompeDocumentation", {link = "Pmenu"})

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
      -- nvim-ts-rainbow
      {"rainbowcol1", {guifg = "#a3be8c"}},
      {"rainbowcol2", {guifg = "#99c2c1"}},
      {"rainbowcol3", {guifg = "#8fbcbb"}},
      {"rainbowcol4", {guifg = "#88c0d0"}},
      {"rainbowcol5", {guifg = "#81a1c1"}},
      {"rainbowcol6", {guifg = "#5e81ac"}},
      {"rainbowcol7", {guifg = "#4e6f97"}},
      -- bqf
      {"BqfPreviewBorder", {guifg = modal_border_color}}
      -- indent-blankline
      -- {"IndentBlanklineChar", {guifg = "#3b4252"}},
      -- {"IndentBlanklineContextChar", {guifg = "#4c566a"}},
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
  local cursor_line_bg = M.hl_value("CursorLine", "bg")
  local normal_fg = M.hl_value("Normal", "fg")
  local bg_color = M.darken_color(M.hl_value("Normal", "bg"), -10)
  local comment_fg = M.hl_value("Comment", "fg")

  M.all(
    {
      {"CursorLineNr", {gui = "bold"}},
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
      {"LspReferenceText", {guibg = cursor_line_bg}},
      {"LspReferenceRead", {guibg = cursor_line_bg}},
      -- Notifications
      {"NvimNotificationError", {link = "ErrorMsg"}},
      {"NvimNotificationInfo", {link = "Directory"}}
    }
  )
end

function M.darken_color(color, amount)
  local success, module = pcall(require, "bufferline")
  if not success then
    vim.notify("Failed to load bufferline", 2, {})
    return color
  else
    return module.shade_color(color, amount)
  end
end

local function set_sidebar_highlight()
  local split_color = M.hl_value("VertSplit", "fg")
  local bg_color = M.darken_color(M.hl_value("Normal", "bg"), -10)
  local st_color = M.darken_color(M.hl_value("Normal", "bg"), -16)
  local hls = {
    {"PanelBackground", {guibg = bg_color}},
    {"PanelHeading", {guibg = bg_color, gui = "bold"}},
    {"PanelVertSplit", {guifg = split_color, guibg = bg_color}},
    {"PanelStNC", {guibg = st_color, cterm = "italic"}},
    {"PanelSt", {guibg = st_color}}
  }
  for _, grp in ipairs(hls) do
    M.highlight(unpack(grp))
  end
end

local sidebar_fts = {"NvimTree"}

function M.on_sidebar_enter()
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

function M.clear_hl(name)
  if not name then
    return
  end
  vim.cmd(fmt("highlight clear %s", name))
end

local function colorscheme_overrides()
  if vim.g.colors_name == "tokyonight" then
    local keyword_fg = M.hl_value("Keyword", "fg")
    local dark_bg = M.darken_color(M.hl_value("Normal", "bg"), -6)
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

function M.apply_user_highlights()
  plugin_highlights()
  general_overrides()
  colorscheme_overrides()
  set_sidebar_highlight()
end

fss.augroup(
  "PanelHighlights",
  {
    {
      events = {"VimEnter", "ColorScheme"},
      targets = {"*"},
      command = M.apply_user_highlights
    },
    {
      events = {"FileType"},
      targets = sidebar_fts,
      command = M.on_sidebar_enter
    }
  }
)

return M