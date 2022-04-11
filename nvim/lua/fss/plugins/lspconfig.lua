fss.lsp = {}
local fmt = string.format

-----------------------------------------------------------------------------//
-- Autocommands
-----------------------------------------------------------------------------//

--- Add lsp autocommands
---@param client table<string, any>
---@param bufnr number
local function setup_autocommands(client, bufnr)
  if client and client.resolved_capabilities.code_lens then
    fss.augroup('LspCodeLens', {
      {
        event = { 'BufEnter', 'CursorHold', 'InsertLeave' },
        buffer = bufnr,
        command = function()
          vim.lsp.codelens.refresh()
        end,
      },
    })
  end
  if client and client.resolved_capabilities.document_highlight then
    fss.augroup('LspCursorCommands', {
      {
        event = { 'CursorHold' },
        buffer = bufnr,
        command = function()
          vim.diagnostic.open_float(nil, { focus = false })
        end,
      },
      {
        event = { 'CursorHold', 'CursorHoldI' },
        description = 'LSP: Document Highlight',
        buffer = bufnr,
        command = function()
          vim.lsp.buf.document_highlight()
        end,
      },
      {
        event = { 'CursorMoved' },
        description = 'LSP: Document Highlight (Clear)',
        buffer = bufnr,
        command = function()
          vim.lsp.buf.clear_references()
        end,
      },
    })
  end
  if client and client.resolved_capabilities.document_formatting then
    -- format on save
    fss.augroup('LspFormat', {
      {
        event = 'BufWritePre',
        buffer = 0,
        command = function()
          local ok, msg = pcall(vim.lsp.buf.formatting_sync, nil, 2000)
          if not ok then
            vim.notify(fmt('Error formatting file: %s', msg))
          end
        end,
      },
    })
  end
end

-----------------------------------------------------------------------------//
-- Mappings
-----------------------------------------------------------------------------//

---Setup mapping when an lsp attaches to a buffer
---@param client table lsp client
local function setup_mappings(client)
  local maps = {
    n = {
      ['<leader>rf'] = { vim.lsp.buf.formatting, 'lsp: format buffer' },
      gd = { vim.lsp.buf.definition, 'lsp: definition' },
      gr = { vim.lsp.buf.references, 'lsp: references' },
      gI = { vim.lsp.buf.incoming_calls, 'lsp: incoming calls' },
      K = { vim.lsp.buf.hover, 'lsp: hover' },
    },
    x = {},
  }

  maps.n[']c'] = {
    function()
      vim.diagnostic.goto_next()
    end,
    'lsp: go to prev diagnostic',
  }
  maps.n['[c'] = {
    function()
      vim.diagnostic.goto_next()
    end,
    'lsp: go to next diagnostic',
  }

  if client.resolved_capabilities.implementation then
    maps.n['gi'] = { vim.lsp.buf.implementation, 'lsp: implementation' }
  end

  if client.resolved_capabilities.type_definition then
    maps.n['<leader>gd'] = {
      vim.lsp.buf.type_definition,
      'lsp: go to type definition',
    }
  end

  maps.n['<leader>ca'] = { vim.lsp.buf.code_action, 'lsp: code action' }
  maps.x['<leader>ca'] = {
    '<esc><Cmd>lua vim.lsp.buf.range_code_action()<CR>',
    'lsp: code action',
  }

  if client.supports_method 'textDocument/rename' then
    maps.n['<leader>rn'] = { vim.lsp.buf.rename, 'lsp: rename' }
  end

  for mode, value in pairs(maps) do
    require('which-key').register(value, { buffer = 0, mode = mode })
  end
end

function fss.lsp.tagfunc(pattern, flags)
  if flags ~= 'c' then
    return vim.NIL
  end
  local params = vim.lsp.util.make_position_params()
  local client_id_to_results, err = vim.lsp.buf_request_sync(
    0,
    'textDocument/definition',
    params,
    500
  )
  assert(not err, vim.inspect(err))

  local results = {}
  for _, lsp_results in ipairs(client_id_to_results) do
    for _, location in ipairs(lsp_results.result or {}) do
      local start = location.range.start
      table.insert(results, {
        name = pattern,
        filename = vim.uri_to_fname(location.uri),
        cmd = string.format(
          'call cursor(%d, %d)',
          start.line + 1,
          start.character + 1
        ),
      })
    end
  end
  return results
end

local function tsserver_on_attach(client, bufnr)
  setup_autocommands(client, bufnr)
  setup_mappings(client)

  if client.resolved_capabilities.goto_definition then
    vim.bo[bufnr].tagfunc = 'v:lua.fss.lsp.tagfunc'
  end

  client.resolved_capabilities.document_formatting = false
  client.resolved_capabilities.document_range_formatting = false

  local ts_utils = require 'nvim-lsp-ts-utils'

  -- defaults
  ts_utils.setup {
    debug = true,
    disable_commands = false,
    enable_import_on_completion = true,

    -- import all
    import_all_timeout = 5000, -- ms
    import_all_priorities = {
      buffers = 4, -- loaded buffer names
      buffer_content = 3, -- loaded buffer content
      local_files = 2, -- git files or files with relative path markers
      same_file = 1, -- add to existing import statement
    },
    import_all_scan_buffers = 100,
    import_all_select_source = false,

    -- eslint
    eslint_enable_code_actions = false,
    eslint_enable_disable_comments = false,
    eslint_bin = 'eslint_d',
    eslint_enable_diagnostics = false,
    eslint_opts = {},

    -- formatting
    enable_formatting = false,
    formatter = 'prettier_d_slim',
    formatter_opts = {},

    -- update imports on file move
    update_imports_on_move = false,
    require_confirmation_on_move = true,
    watch_dir = nil,

    -- filter diagnostics
    filter_out_diagnostics_by_severity = {},
    filter_out_diagnostics_by_code = { 80001 },
  }

  -- required to fix code action ranges and filter diagnostics
  ts_utils.setup_client(client)
end

function fss.lsp.on_attach(client, bufnr)
  require('illuminate').on_attach(client)
  setup_autocommands(client, bufnr)
  setup_mappings(client)

  if client.resolved_capabilities.goto_definition then
    vim.bo[bufnr].tagfunc = 'v:lua.fss.lsp.tagfunc'
  end
end

-----------------------------------------------------------------------------//
-- Language servers
-----------------------------------------------------------------------------//

fss.lsp.servers = {
  bashls = true,
  tsserver = true,
  elixirls = true,
  sumneko_lua = function()
    local ok, lua_dev = fss.safe_require 'lua-dev'
    if not ok then
      return {}
    end
    return lua_dev.setup {
      library = {
        plugins = { 'plenary.nvim' },
      },
      lspconfig = {
        settings = {
          Lua = {
            diagnostics = {
              globals = {
                'vim',
                'describe',
                'it',
                'before_each',
                'after_each',
                'pending',
                'teardown',
                'packer_plugins',
              },
            },
            completion = {
              keywordSnippet = 'Replace',
              callSnippet = 'Replace',
            },
          },
        },
      },
    }
  end,
}

--Logic to (re)start installed language servers for use initialising lsps
---and restarting them on installing new ones
function fss.lsp.get_server_config(server)
  local nvim_lsp_ok, cmp_nvim_lsp = fss.safe_require 'cmp_nvim_lsp'
  local conf = fss.lsp.servers[server.name]
  local conf_type = type(conf)
  local config = conf_type == 'table' and conf
    or conf_type == 'function' and conf()
    or {}
  config.flags = { debounce_text_changes = 500 }
  config.capabilities = config.capabilities
    or vim.lsp.protocol.make_client_capabilities()
  if server.name == 'tsserver' then
    config.on_attach = tsserver_on_attach
  else
    config.on_attach = fss.lsp.on_attach
  end

  if nvim_lsp_ok then
    cmp_nvim_lsp.update_capabilities(config.capabilities)
  end
  return config
end

return function()
  local lsp_installer = require 'nvim-lsp-installer'
  lsp_installer.on_server_ready(function(server)
    server:setup(fss.lsp.get_server_config(server))
  end)
end
