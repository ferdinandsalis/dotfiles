fss.lsp = {}

-----------------------------------------------------------------------------//
-- Autocommands
-----------------------------------------------------------------------------//

local function setup_autocommands(client, _)
  if client and client.resolved_capabilities.code_lens then
    fss.augroup('LspCodeLens', {
      {
        events = { 'BufEnter', 'CursorHold', 'InsertLeave' },
        targets = { '<buffer>' },
        command = vim.lsp.codelens.refresh,
      },
    })
  end
  if client and client.resolved_capabilities.document_highlight then
    fss.augroup('LspCursorCommands', {
      {
        events = { 'CursorHold' },
        targets = { '<buffer>' },
        command = vim.lsp.buf.document_highlight,
      },
      {
        events = { 'CursorHoldI' },
        targets = { '<buffer>' },
        command = vim.lsp.buf.document_highlight,
      },
      {
        events = { 'CursorMoved' },
        targets = { '<buffer>' },
        command = vim.lsp.buf.clear_references,
      },
    })
  end
  if client and client.resolved_capabilities.document_formatting then
    -- format on save
    fss.augroup('LspFormat', {
      {
        events = { 'BufWritePre' },
        targets = { '<buffer>' },
        command = function()
          -- BUG: folds are are removed when formatting is done, so we save the current state of the
          -- view and re-apply it manually after formatting the buffer
          -- @see: https://github.com/nvim-treesitter/nvim-treesitter/issues/1424#issuecomment-909181939
          vim.cmd 'mkview!'
          vim.lsp.buf.formatting_sync()
          vim.cmd 'loadview'
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
---@param bufnr integer?
local function setup_mappings(client, bufnr)
  local maps = {
    ['<leader>rf'] = { vim.lsp.buf.formatting, 'lsp: format buffer' },
    ['gi'] = 'lsp: implementation',
    ['gd'] = { vim.lsp.buf.definition, 'lsp: definition' },
    ['gr'] = { vim.lsp.buf.references, 'lsp: references' },
    ['gI'] = { vim.lsp.buf.incoming_calls, 'lsp: incoming calls' },
    ['K'] = { vim.lsp.buf.hover, 'lsp: hover' },
  }

  -- FIXME: remove when 0.6 is released
  local goto_key = fss.nightly and 'float' or 'popup_opts'
  local diagnostics = fss.nightly and vim.diagnostic or vim.lsp.diagnostic

  maps[']c'] = {
    function()
      diagnostics.goto_prev {
        [goto_key] = {
          border = 'rounded',
          focusable = false,
          source = 'always',
        },
      }
    end,
    'lsp: go to prev diagnostic',
  }
  maps['[c'] = {
    function()
      diagnostics.goto_next {
        [goto_key] = {
          border = 'rounded',
          focusable = false,
          source = 'always',
        },
      }
    end,
    'lsp: go to next diagnostic',
  }

  if client.resolved_capabilities.implementation then
    maps['gi'] = { vim.lsp.buf.implementation, 'lsp: impementation' }
  end

  if client.resolved_capabilities.type_definition then
    maps['<leader>gd'] = { vim.lsp.buf.type_definition, 'lsp: go to type definition' }
  end

  if not fss.has_map('<leader>ca', 'n') then
    maps['<leader>ca'] = { vim.lsp.buf.code_action, 'lsp: code action' }
    -- TODO: not sure that this works, since these keys likely override each other in which key
    maps['<leader>ca'] = { vim.lsp.buf.range_code_action, 'lsp: code action', mode = 'x' }
  end

  if client.supports_method 'textDocument/rename' then
    local renamer = require('renamer').rename or vim.lsp.buf.rename
    maps['<leader>rn'] = { renamer, 'lsp: rename' }
  end

  require('which-key').register(maps, { buffer = 0 })
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
        cmd = string.format('call cursor(%d, %d)', start.line + 1, start.character + 1),
      })
    end
  end
  return results
end

local function tsserver_on_attach(client, bufnr)
  setup_autocommands(client, bufnr)
  setup_mappings(client, bufnr)

  if client.resolved_capabilities.goto_definition then
    vim.bo[bufnr].tagfunc = 'v:lua.fss.lsp.tagfunc'
  end

  require('lsp-status').on_attach(client)

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
    eslint_enable_code_actions = true,
    eslint_enable_disable_comments = true,
    eslint_bin = 'eslint_d',
    eslint_enable_diagnostics = false,
    eslint_opts = {},

    -- formatting
    enable_formatting = false,
    formatter = 'prettierd',
    formatter_opts = {},

    -- update imports on file move
    update_imports_on_move = false,
    require_confirmation_on_move = false,
    watch_dir = nil,

    -- filter diagnostics
    filter_out_diagnostics_by_severity = {},
    filter_out_diagnostics_by_code = { 80001 },
  }

  -- required to fix code action ranges and filter diagnostics
  ts_utils.setup_client(client)
end

function fss.lsp.on_attach(client, bufnr)
  setup_autocommands(client, bufnr)
  setup_mappings(client, bufnr)

  if client.resolved_capabilities.goto_definition then
    vim.bo[bufnr].tagfunc = 'v:lua.fss.lsp.tagfunc'
  end

  require('lsp-status').on_attach(client)
end

-----------------------------------------------------------------------------//
-- Language servers
-----------------------------------------------------------------------------//

fss.lsp.servers = {
  bashls = true,
  tsserver = true,
  elixirls = true,
    jsonls = function()
    return {
      settings = {
        json = {
          schemas = require('schemastore').json.schemas(),
        },
      },
    }
  end,
  --- NOTE: This is the secret sauce that allows reading requires and variables
  --- between different modules in the nvim lua context
  --- @see https://gist.github.com/folke/fe5d28423ea5380929c3f7ce674c41d8
  --- if I ever decide to move away from lua dev then use the above
  sumneko_lua = require('lua-dev').setup {
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
          completion = { keywordSnippet = 'Replace', callSnippet = 'Replace' },
        },
      },
    },
  },
}

--Logic to (re)start installed language servers for use initialising lsps
---and restarting them on installing new ones
function fss.lsp.get_server_config(server)
  local nvim_lsp_ok, cmp_nvim_lsp = fss.safe_require 'cmp_nvim_lsp'
  local status_capabilities = require('lsp-status').capabilities
  local conf = fss.lsp.servers[server.name]
  local config = type(conf) == 'table' and conf or {}
  config.flags = { debounce_text_changes = 500 }
  config.on_attach = fss.lsp.on_attach
  if server.name == 'tsserver' then
    config.on_attach = tsserver_on_attach
  else
    config.on_attach = fss.lsp.on_attach
  end

  config.capabilities = config.capabilities or vim.lsp.protocol.make_client_capabilities()
  if nvim_lsp_ok then
    cmp_nvim_lsp.update_capabilities(config.capabilities)
  end
  config.capabilities = fss.deep_merge(status_capabilities, config.capabilities)
  return config
end

return function()
  if vim.g.lspconfig_has_setup then
    return
  end
  vim.g.lspconfig_has_setup = true

  local lsp_installer = require 'nvim-lsp-installer'
  lsp_installer.on_server_ready(function(server)
    server:setup(fss.lsp.get_server_config(server))
    vim.cmd [[ do User LspAttachBuffers ]]
  end)
end
