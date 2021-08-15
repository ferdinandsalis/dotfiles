local fn = vim.fn
local api = vim.api
local fmt = string.format
-----------------------------------------------------------------------------//
-- Global namespace
-----------------------------------------------------------------------------//
--- Inspired by @tjdevries' astraunauta.nvim/ @TimUntersberger's config
--- store all callbacks in one global table so they are able to survive re-requiring this file
_G.__as_global_callbacks = __as_global_callbacks or {}

_G.fss = {
  _store = __as_global_callbacks,
  --- work around to place functions in the global scope but namespaced within a table.
  --- TODO: refactor this once nvim allows passing lua functions to mappings
  mappings = {},
}

-----------------------------------------------------------------------------//
-- UI
-----------------------------------------------------------------------------//
-- Consistent store of various UI items to reuse throughout my config
fss.style = {
  icons = {
    error = '', -- 
    warning = '',
    info = '',
    hint = '',
  },
  border = {
    curved = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
  },
  palette = {
    white = '#c0caf5',
    dark_red = '#db4b4b',
    green = '#9ece6a',
    light_yellow = '#e0af68',
    dark_blue = '#3d59a1',
    magenta = '#bb9af7',
    comment_grey = '#565f89',
    whitesmoke = '#3b4261',
    bright_blue = '#7aa2f7',
  },
}

-----------------------------------------------------------------------------//
-- Debugging
-----------------------------------------------------------------------------//
if pcall(require, 'plenary') then
  RELOAD = require('plenary.reload').reload_module

  R = function(name)
    RELOAD(name)
    return require(name)
  end
end

-- inspect the contents of an object very quickly
-- in your code or from the command-line:
-- USAGE:
-- in lua: dump({1, 2, 3})
-- in commandline: :lua dump(vim.loop)
---@vararg any
function P(...)
  local objects = vim.tbl_map(vim.inspect, { ... })
  print(unpack(objects))
end

local installed
---Check if a plugin is on the system not whether or not it is loaded
---@param plugin_name string
---@return boolean
function fss.plugin_installed(plugin_name)
  if not installed then
    local dirs = fn.expand(fn.stdpath 'data' .. '/site/pack/packer/start/*', true, true)
    local opt = fn.expand(fn.stdpath 'data' .. '/site/pack/packer/opt/*', true, true)
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
function _G.plugin_loaded(plugin_name)
  local plugins = packer_plugins or {}
  return plugins[plugin_name] and plugins[plugin_name].loaded
end
-----------------------------------------------------------------------------//
-- Utils
-----------------------------------------------------------------------------//
function fss._create(f)
  table.insert(fss._store, f)
  return #fss._store
end

function fss._execute(id, args)
  fss._store[id](args)
end

---@class Autocommand
---@field events string[] list of autocommand events
---@field targets string[] list of autocommand patterns
---@field modifiers string[] e.g. nested, once
---@field command string | function

---@param command Autocommand
local function is_valid_target(command)
  local valid_type = command.targets and vim.tbl_islist(command.targets)
  return valid_type or vim.startswith(command.events[1], 'User ')
end

local L = vim.log.levels
---Create an autocommand
---@param name string
---@param commands Autocommand[]
function fss.augroup(name, commands)
  vim.cmd('augroup ' .. name)
  vim.cmd 'autocmd!'
  for _, c in ipairs(commands) do
    if c.command and c.events and is_valid_target(c) then
      local command = c.command
      if type(command) == 'function' then
        local fn_id = fss._create(command)
        command = fmt('lua fss._execute(%s)', fn_id)
      end
      vim.cmd(
        string.format(
          'autocmd %s %s %s %s',
          table.concat(c.events, ','),
          table.concat(c.targets or {}, ','),
          table.concat(c.modifiers or {}, ' '),
          command
        )
      )
    else
      vim.notify(
        fmt('An autocommand in %s is specified incorrectly: %s', name, vim.inspect(name)),
        L.ERROR
      )
    end
  end
  vim.cmd 'augroup END'
end

---Source a lua or vimscript file
---@param path string path relative to the nvim directory
function fss.source(path)
  vim.cmd(fmt('source %s/%s', vim.g.vim_dir, path))
end

---Require a module using [pcall] and report any errors
---@param module string
---@param opts table?
---@return boolean, any
function fss.safe_require(module, opts)
  opts = opts or { silent = false }
  local ok, err = pcall(require, module)
  if not ok and not opts.silent then
    vim.notify(err, L.ERROR, { title = fmt('Error requiring: %s', module) })
  end
  return ok, err
end

---Check if a cmd is executable
---@param e string
---@return boolean
function fss.executable(e)
  return fn.executable(e) > 0
end

---Echo a msg to the commandline
---@param msg string | table
---@param hl string
function fss.echomsg(msg, hl)
  hl = hl or 'Title'
  local msg_type = type(msg)
  assert(
    msg_type ~= 'string' or msg_type ~= 'table',
    fmt('message should be a string or list of strings not a %s', msg_type)
  )
  if msg_type == 'string' then
    msg = { { msg, hl } }
  end
  vim.api.nvim_echo(msg, true, {})
end

-- https://stackoverflow.com/questions/1283388/lua-merge-tables
function fss.deep_merge(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == 'table') and (type(t1[k] or false) == 'table') then
      fss.deep_merge(t1[k], t2[k])
    else
      t1[k] = v
    end
  end
  return t1
end

---A terser proxy for `nvim_replace_termcodes`
---@param str string
---@return any
function fss.replace_termcodes(str)
  return api.nvim_replace_termcodes(str, true, true, true)
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

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function fss.has(feature)
  return vim.fn.has(feature) > 0
end

---Check if directory exists using vim's isdirectory function
---@param path string
---@return boolean
function fss.is_dir(path)
  return fn.isdirectory(path) > 0
end

---Check if a vim variable usually a number is truthy or not
---@param value integer
function fss.truthy(value)
  assert(type(value) == 'number', fmt('Value should be a number but you passed %s', value))
  return value > 0
end

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

---check if a mapping already exists
---@param lhs string
---@param mode string
---@return boolean
function fss.has_map(lhs, mode)
  mode = mode or 'n'
  return vim.fn.maparg(lhs, mode) ~= ''
end

---create a mapping function factory
---@param mode string
---@param o table
---@return fun(lhs: string, rhs: string, opts: table|nil) 'create a mapping'
local function make_mapper(mode, o)
  -- copy the opts table as extends will mutate the opts table passed in otherwise
  local parent_opts = vim.deepcopy(o)
  ---Create a mapping
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts table
  return function(lhs, rhs, opts)
    assert(lhs ~= mode, fmt('The lhs should not be the same as mode for %s', lhs))
    assert(type(rhs) == 'string' or type(rhs) == 'function', '"rhs" should be a function or string')
    opts = opts and vim.deepcopy(opts) or {}

    local buffer = opts.buffer
    opts.buffer = nil
    if type(rhs) == 'function' then
      local fn_id = fss._create(rhs)
      rhs = string.format('<cmd>lua fss._execute(%s)<CR>', fn_id)
    end

    if buffer and type(buffer) == 'number' then
      opts = vim.tbl_extend('keep', opts, parent_opts)
      api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, opts)
      return
    end

    api.nvim_set_keymap(mode, lhs, rhs, vim.tbl_extend('keep', opts, parent_opts))
  end
end

local map_opts = { noremap = false, silent = true }
local noremap_opts = { noremap = true, silent = true }

fss.nmap = make_mapper('n', map_opts)
fss.xmap = make_mapper('x', map_opts)
fss.imap = make_mapper('i', map_opts)
fss.vmap = make_mapper('v', map_opts)
fss.omap = make_mapper('o', map_opts)
fss.tmap = make_mapper('t', map_opts)
fss.smap = make_mapper('s', map_opts)
fss.cmap = make_mapper('c', { noremap = false, silent = false })

fss.nnoremap = make_mapper('n', noremap_opts)
fss.xnoremap = make_mapper('x', noremap_opts)
fss.vnoremap = make_mapper('v', noremap_opts)
fss.inoremap = make_mapper('i', noremap_opts)
fss.onoremap = make_mapper('o', noremap_opts)
fss.tnoremap = make_mapper('t', noremap_opts)
fss.snoremap = make_mapper('s', noremap_opts)
fss.cnoremap = make_mapper('c', { noremap = true, silent = false })

function fss.command(args)
  local nargs = args.nargs or 0
  local name = args[1]
  local rhs = args[2]
  local types = (args.types and type(args.types) == 'table') and table.concat(args.types, ' ') or ''

  if type(rhs) == 'function' then
    local fn_id = fss._create(rhs)
    rhs = string.format('lua fss._execute(%d%s)', fn_id, nargs > 0 and ', <f-args>' or '')
  end

  vim.cmd(string.format('command! -nargs=%s %s %s %s', nargs, types, name, rhs))
end

function fss.invalidate(path, recursive)
  if recursive then
    for key, value in pairs(package.loaded) do
      if key ~= '_G' and value and vim.fn.match(key, path) ~= -1 then
        package.loaded[key] = nil
        require(key)
      end
    end
  else
    package.loaded[path] = nil
    require(path)
  end
end
