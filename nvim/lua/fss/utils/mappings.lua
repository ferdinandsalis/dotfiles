-----------------------------------------------------------------------------//
-- MAPPINGS
-----------------------------------------------------------------------------//
-- A very over-engineered mapping mini-module. Yes, I know I could have used one
-- a number of plugins and be done with it.
-- e.g
-- - https://github.com/b0o/mapx.nvim [The Best Option]
-- - https://github.com/svermeulen/vimpeccable [The Original]
--
-- But frankly I like to be in control of my mappings and I honestly think that very soon this
-- won't be needed as mappings are likely to become simpler once the native api is improved

local api = vim.api
local fmt = string.format

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
    -- If the label is all that was passed in, set the opts automagically
    opts = type(opts) == 'string' and { label = opts } or opts and vim.deepcopy(opts) or {}

    local buffer = opts.buffer
    opts.buffer = nil
    if type(rhs) == 'function' then
      local fn_id = fss._create(rhs)
      rhs = string.format('<cmd>lua fss._execute(%s)<CR>', fn_id)
    end

    if opts.label then
      local ok, wk = fss.safe_require('which-key', { silent = true })
      if ok then
        wk.register({ [lhs] = opts.label }, { mode = mode })
      end
      opts.label = nil
    end

    opts = vim.tbl_extend('keep', opts, parent_opts)
    if buffer and type(buffer) == 'number' then
      return api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, opts)
    end

    api.nvim_set_keymap(mode, lhs, rhs, opts)
  end
end

local map_opts = { noremap = false, silent = true }
local noremap_opts = { noremap = true, silent = true }

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
fss.cmap = make_mapper('c', { noremap = false, silent = false })
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
fss.cnoremap = make_mapper('c', { noremap = true, silent = false })

---Factory function to create multi mode map functions
---e.g. `fss.map({"n", "s"}, lhs, rhs, opts)`
---@param target string
---@return fun(modes: string[], lhs: string, rhs: string, opts: table)
local function multimap(target)
  return function(modes, lhs, rhs, opts)
    for _, m in ipairs(modes) do
      fss[m .. target](lhs, rhs, opts)
    end
  end
end

fss.map = multimap 'map'
fss.noremap = multimap 'noremap'