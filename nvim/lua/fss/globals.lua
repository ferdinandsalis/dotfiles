local fn = vim.fn
local api = vim.api
local fmt = string.format

-----------------------------------------------------------------------------//
-- Global namespace
-----------------------------------------------------------------------------//

_G.fss = {
  -- some vim mappings require a mixture of commandline commands and function calls
  -- this table is place to store lua functions to be called in those mappings
  mappings = {},
}

-----------------------------------------------------------------------------//
-- Styles
-----------------------------------------------------------------------------//

-- Consistent store of various UI items to reuse throughout my config
local palette = {
  none = 'NONE',
  bg_dark = '#1f2335',
  bg = '#24283b',
  bg_highlight = '#292e42',
  terminal_black = '#414868',
  fg = '#c0caf5',
  fg_dark = '#a9b1d6',
  fg_gutter = '#3b4261',
  comment = '#565f89',
  git = {
    change = '#6183bb',
    add = '#449dab',
    delete = '#914c54',
    conflict = '#bb7a61',
  },
  gitSigns = { add = '#164846', change = '#394b70', delete = '#823c41' },
  dark3 = '#545c7e',
  dark5 = '#737aa2',
  blue0 = '#3d59a1',
  blue = '#7aa2f7',
  cyan = '#7dcfff',
  blue1 = '#2ac3de',
  blue2 = '#0db9d7',
  blue5 = '#89ddff',
  blue6 = '#B4F9F8',
  blue7 = '#394b70',
  magenta = '#bb9af7',
  magenta2 = '#ff007c',
  purple = '#9d7cd8',
  orange = '#ff9e64',
  yellow = '#e0af68',
  green = '#9ece6a',
  green1 = '#73daca',
  green2 = '#41a6b5',
  teal = '#1abc9c',
  red = '#f7768e',
  red1 = '#db4b4b',
}

fss.style = {
  icons = {
    lsp = {
      error = ' ',
      warn = ' ',
      hint = ' ',
      info = ' ',
    },
    git = {
      add = '', -- '',
      mod = '', -- '',
      remove = '', --
      ignore = '',
      rename = '',
      diff = '',
      repo = '',
    },
    documents = {
      file = '',
      files = '',
      folder = '',
      open_folder = '',
    },
    type = {
      array = '',
      number = '',
      object = '',
    },
    misc = {
      up = '⇡',
      down = '⇣',
      line = 'ℓ', -- ''
      indent = 'Ξ',
      tab = '⇥',
      bug = '', -- 'ﴫ'
      question = '',
      lock = '',
      circle = '',
      project = '',
      dashboard = '',
      history = '',
      comment = '',
      robot = 'ﮧ',
      lightbulb = '',
      search = '',
      code = '',
      telescope = '',
      gear = '',
      package = '',
      list = '',
      sign_in = '',
      check = '',
      fire = '',
      note = '',
      bookmark = '',
      pencil = '',
      tools = '',
      chevron_right = '',
      double_chevron_right = '»',
      table = '',
      calendar = '',
      block = '▌',
    },
  },
  float = {
    blend = 0,
  },
  border = {
    line = {
      { '🭽', 'FloatBorder' },
      { '▔', 'FloatBorder' },
      { '🭾', 'FloatBorder' },
      { '▕', 'FloatBorder' },
      { '🭿', 'FloatBorder' },
      { '▁', 'FloatBorder' },
      { '🭼', 'FloatBorder' },
      { '▏', 'FloatBorder' },
    },
  },
  lsp = {
    colors = {
      error = palette.red1,
      warn = palette.orange,
      hint = palette.yellow,
      info = palette.teal,
    },
    kind_highlights = {
      Text = 'String',
      Method = 'Method',
      Function = 'Function',
      Constructor = 'TSConstructor',
      Field = 'Field',
      Variable = 'Variable',
      Class = 'Class',
      Interface = 'Constant',
      Module = 'Include',
      Property = 'Property',
      Unit = 'Constant',
      Value = 'Variable',
      Enum = 'Type',
      Keyword = 'Keyword',
      File = 'Directory',
      Reference = 'PreProc',
      Constant = 'Constant',
      Struct = 'Type',
      Snippet = 'Label',
      Event = 'Variable',
      Operator = 'Operator',
      TypeParameter = 'Type',
    },
    kinds = {
      Text = '',
      Method = '',
      Function = '',
      Constructor = '',
      Field = '', -- '',
      Variable = '', -- '',
      Class = '', -- '',
      Interface = '',
      Module = '',
      Property = 'ﰠ',
      Unit = '塞',
      Value = '',
      Enum = '',
      Keyword = '', -- '',
      Snippet = '', -- '', '',
      Color = '',
      File = '',
      Reference = '', -- '',
      Folder = '',
      EnumMember = '',
      Constant = '', -- '',
      Struct = '', -- 'פּ',
      Event = '',
      Operator = '',
      TypeParameter = '',
    },
  },
  palette = palette,
}

----------------------------------------------------------------------------------------------------
-- Utils
----------------------------------------------------------------------------------------------------

---Find an item in a list
---@generic T
---@param haystack T[]
---@param matcher fun(arg: T):boolean
---@return T
function fss.find(haystack, matcher)
  local found
  for _, needle in ipairs(haystack) do
    if matcher(needle) then
      found = needle
      break
    end
  end
  return found
end

local installed
---Check if a plugin is on the system not whether or not it is loaded
---@param plugin_name string
---@return boolean
function fss.plugin_installed(plugin_name)
  if not installed then
    local dirs = fn.expand(
      fn.stdpath 'data' .. '/site/pack/packer/start/*',
      true,
      true
    )
    local opt = fn.expand(
      fn.stdpath 'data' .. '/site/pack/packer/opt/*',
      true,
      true
    )
    vim.list_extend(dirs, opt)
    installed = vim.tbl_map(function(path)
      return fn.fnamemodify(path, ':t')
    end, dirs)
  end
  return vim.tbl_contains(installed, plugin_name)
end

---NOTE: this plugin returns the currently loaded state of a plugin given
---given certain assumptions i.e. it will only be true if the plugin has been
---loaded e.g. lazy loading will return false
---@param plugin_name string
---@return boolean?
function fss.plugin_loaded(plugin_name)
  local plugins = packer_plugins or {}
  return plugins[plugin_name] and plugins[plugin_name].loaded
end

---Check whether or not the location or quickfix list is open
---@return boolean
function fss.is_vim_list_open()
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    local location_list = fn.getloclist(0, { filewinid = 0 })
    local is_loc_list = location_list.filewinid > 0
    if vim.bo[buf].filetype == 'qf' or is_loc_list then
      return true
    end
  end
  return false
end

---Determine if a value of any type is empty
---@param item any
---@return boolean
function fss.empty(item)
  if not item then
    return true
  end
  local item_type = type(item)
  if item_type == 'string' then
    return item == ''
  elseif item_type == 'table' then
    return vim.tbl_isempty(item)
  end
end

---Require a module using [pcall] and report any errors
---@param module string
---@param opts table?
---@return boolean, any
function fss.safe_require(module, opts)
  opts = opts or { silent = false }
  local ok, result = pcall(require, module)
  if not ok and not opts.silent then
    vim.notify(
      result,
      vim.log.levels.ERROR,
      { title = fmt('Error requiring: %s', module) }
    )
  end
  return ok, result
end

---Reload lua modules
---@param path string
---@param recursive string
function fss.invalidate(path, recursive)
  if recursive then
    for key, value in pairs(package.loaded) do
      if key ~= '_G' and value and fn.match(key, path) ~= -1 then
        package.loaded[key] = nil
        require(key)
      end
    end
  else
    package.loaded[path] = nil
    require(path)
  end
end

--- Usage:
--- 1. Call `local stop = utils.profile('my-log')` at the top of the file
--- 2. At the bottom of the file call `stop()`
--- 3. Restart neovim, the newly created log file should open
function fss.profile(filename)
  local base = '/tmp/config/profile/'
  fn.mkdir(base, 'p')
  local success, profile = pcall(require, 'plenary.profile.lua_profiler')
  if not success then
    vim.api.nvim_echo({ 'Plenary is not installed.', 'Title' }, true, {})
  end
  profile.start()
  return function()
    profile.stop()
    local logfile = base .. filename .. '.log'
    profile.report(logfile)
    vim.defer_fn(function()
      vim.cmd('tabedit ' .. logfile)
    end, 1000)
  end
end

----------------------------------------------------------------------------------------------------
-- API Wrappers
----------------------------------------------------------------------------------------------------
-- Thin wrappers over API functions to make their usage easier/terser

---@class Autocommand
---@field description string
---@field event  string[] list of autocommand events
---@field pattern string[] list of autocommand patterns
---@field command string | function
---@field nested  boolean
---@field once    boolean
---@field buffer  number

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string
---@param commands Autocommand[]
---@return number
function fss.augroup(name, commands)
  local id = api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(commands) do
    local is_callback = type(autocmd.command) == 'function'
    api.nvim_create_autocmd(autocmd.event, {
      group = id,
      pattern = autocmd.pattern,
      desc = autocmd.description,
      callback = is_callback and autocmd.command or nil,
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end
  return id
end

--- @class CommandArgs
--- @field args string
--- @field fargs table
--- @field bang boolean,

---Create an nvim command
---@param name any
---@param rhs string|fun(args: CommandArgs)
---@param opts table
function fss.command(name, rhs, opts)
  opts = opts or {}
  api.nvim_add_user_command(name, rhs, opts)
end

---Source a lua or vimscript file
---@param path string path relative to the nvim directory
---@param prefix boolean?
function fss.source(path, prefix)
  if not prefix then
    vim.cmd(fmt('source %s', path))
  else
    vim.cmd(fmt('source %s/%s', vim.g.vim_dir, path))
  end
end

---Check if a cmd is executable
---@param e string
---@return boolean
function fss.executable(e)
  return fn.executable(e) > 0
end

---A terser proxy for `nvim_replace_termcodes`
---@param str string
---@return any
function fss.replace_termcodes(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function fss.has(feature)
  return vim.fn.has(feature) > 0
end

fss.nightly = fss.has 'nvim-0.7'

----------------------------------------------------------------------------------------------------
-- Mappings
----------------------------------------------------------------------------------------------------

---create a mapping function factory
---@param mode string
---@param o table
---@return fun(lhs: string, rhs: string|function, opts: table|nil) 'create a mapping'
local function make_mapper(mode, o)
  -- copy the opts table as extends will mutate the opts table passed in otherwise
  local parent_opts = vim.deepcopy(o)
  ---Create a mapping
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts table
  return function(lhs, rhs, opts)
    -- If the label is all that was passed in, set the opts automagically
    opts = type(opts) == 'string' and { label = opts }
      or opts and vim.deepcopy(opts)
      or {}
    if opts.label then
      local ok, wk = fss.safe_require('which-key', { silent = true })
      if ok then
        wk.register({ [lhs] = opts.label }, { mode = mode })
      end
      opts.label = nil
    end
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('keep', opts, parent_opts))
  end
end

local map_opts = { remap = true, silent = true }
local noremap_opts = { silent = true }

-- A recursive commandline mapping
fss.nmap = make_mapper('n', map_opts)
-- A recursive select mapping
fss.xmap = make_mapper('x', map_opts)
-- A recursive terminal mapping
fss.imap = make_mapper('i', map_opts)
-- A recursive operator mapping
fss.vmap = make_mapper('v', map_opts)
-- A recursive insert mapping
fss.omap = make_mapper('o', map_opts)
-- A recursive visual & select mapping
fss.tmap = make_mapper('t', map_opts)
-- A recursive visual mapping
fss.smap = make_mapper('s', map_opts)
-- A recursive normal mapping
fss.cmap = make_mapper('c', { remap = true, silent = false })
-- A non recursive normal mapping
fss.nnoremap = make_mapper('n', noremap_opts)
-- A non recursive visual mapping
fss.xnoremap = make_mapper('x', noremap_opts)
-- A non recursive visual & select mapping
fss.vnoremap = make_mapper('v', noremap_opts)
-- A non recursive insert mapping
fss.inoremap = make_mapper('i', noremap_opts)
-- A non recursive operator mapping
fss.onoremap = make_mapper('o', noremap_opts)
-- A non recursive terminal mapping
fss.tnoremap = make_mapper('t', noremap_opts)
-- A non recursive select mapping
fss.snoremap = make_mapper('s', noremap_opts)
-- A non recursive commandline mapping
fss.cnoremap = make_mapper('c', { silent = false })
