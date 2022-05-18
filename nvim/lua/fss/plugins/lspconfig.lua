fss.lsp = {}

-----------------------------------------------------------------------------//
-- Autocommands
-----------------------------------------------------------------------------//

--- Add lsp autocommands
---@param client table<string, any>
---@param bufnr number
local function setup_autocommands(client, bufnr)
  if client and client.server_capabilities.codeLensProvider then
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
  if client and client.server_capabilities.documentHighlightProvider then
    fss.augroup('LspCursorCommands', {
      {
        event = { 'CursorHold' },
        buffer = bufnr,
        command = function()
          vim.diagnostic.open_float({ scope = 'line' }, { focus = false })
        end,
      },
      {
        event = { 'CursorHold', 'CursorHoldI' },
        description = 'LSP: Document Highlight',
        buffer = bufnr,
        command = function()
          pcall(vim.lsp.buf.document_highlight)
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
end

-----------------------------------------------------------------------------//
-- Mappings
-----------------------------------------------------------------------------//

---Setup mapping when an lsp attaches to a buffer
---@param client table lsp client
local function setup_mappings(client)
  local ok = pcall(require, 'lsp-format')
  local format = ok and '<Cmd>Format<CR>' or vim.lsp.buf.formatting
  local function with_desc(desc)
    return { buffer = 0, desc = desc }
  end

  fss.nnoremap(']c', vim.diagnostic.goto_prev, with_desc('lsp: go to prev diagnostic'))
  fss.nnoremap('[c', vim.diagnostic.goto_next, with_desc('lsp: go to next diagnostic'))

  if client.server_capabilities.documentFormattingProvider then
    fss.nnoremap('<leader>rf', format, with_desc('lsp: format buffer'))
  end

  if client.server_capabilities.codeActionProvider then
    fss.nnoremap('<leader>ca', vim.lsp.buf.code_action, with_desc('lsp: code action'))
    fss.xnoremap('<leader>ca', vim.lsp.buf.range_code_action, with_desc('lsp: code action'))
  end

  if client.server_capabilities.definitionProvider then
    fss.nnoremap('gd', vim.lsp.buf.definition, with_desc('lsp: definition'))
  end
  if client.server_capabilities.referencesProvider then
    fss.nnoremap('gr', vim.lsp.buf.references, with_desc('lsp: references'))
  end
  if client.server_capabilities.hoverProvider then
    fss.nnoremap('K', vim.lsp.buf.hover, with_desc('lsp: hover'))
  end

  if client.supports_method('textDocument/prepareCallHierarchy') then
    fss.nnoremap('gI', vim.lsp.buf.incoming_calls, with_desc('lsp: incoming calls'))
  end

  if client.server_capabilities.implementationProvider then
    fss.nnoremap('gi', vim.lsp.buf.implementation, with_desc('lsp: implementation'))
  end

  if client.server_capabilities.typeDefinitionProvider then
    fss.nnoremap('<leader>gd', vim.lsp.buf.type_definition, with_desc('lsp: go to type definition'))
  end

  if client.server_capabilities.codeLensProvider then
    fss.nnoremap('<leader>cl', vim.lsp.codelens.run, with_desc('lsp: run code lens'))
  end

  if client.server_capabilities.renameProvider then
    fss.nnoremap('<leader>rn', vim.lsp.buf.rename, with_desc('lsp: rename'))
  end
end

function fss.lsp.on_attach(client, bufnr)
  setup_autocommands(client, bufnr)
  setup_mappings(client)
  local format_ok, lsp_format = pcall(require, 'lsp-format')
  if format_ok then
    lsp_format.on_attach(client)
  end

  local illuminate_ok, illuminate = pcall(require, 'illuminate')
  if illuminate_ok then
    illuminate.on_attach(client)
  end

  if client.server_capabilities.definitionProvider == true then
    vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
  end

  if client.server_capabilities.documentFormattingProvider == true then
    vim.bo[bufnr].formatexpr = 'v:lua.vim.lsp.formatexpr()'
  end
end

-----------------------------------------------------------------------------//
-- Language servers
-----------------------------------------------------------------------------//

fss.lsp.servers = {
  bashls = true,
  cssls = true,
  elixirls = true,
  graphql = true,
  jsonls = true,
  tailwindcss = true,
  tsserver = function()
    return {
      on_attach = function(client, bufnr)
        fss.lsp.on_attach(client, bufnr)
        local ts_utils = require('nvim-lsp-ts-utils')
        ts_utils.setup({
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
        })
        ts_utils.setup_client(client)

        -- no default maps, so you may want to define some here
        local opts = { silent = true }
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gs', ':TSLspOrganize<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', ':TSLspRenameFile<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', ':TSLspImportAll<CR>', opts)
      end,
    }
  end,
  sumneko_lua = function()
    local settings = {
      settings = {
        Lua = {
          format = { enable = false },
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
    }
    local ok, lua_dev = fss.safe_require('lua-dev')
    if not ok then
      return settings
    end
    return lua_dev.setup({
      library = { plugins = { 'plenary.nvim' } },
      lspconfig = settings,
    })
  end,
}

--Logic to (re)start installed language servers for use initialising lsps
---and restarting them on installing new ones
function fss.lsp.get_server_config(conf)
  local conf_type = type(conf)
  local config = conf_type == 'table' and conf or conf_type == 'function' and conf() or {}
  config.capabilities = config.capabilities or vim.lsp.protocol.make_client_capabilities()
  config.on_attach = config.on_attach or fss.lsp.on_attach
  local nvim_lsp_ok, cmp_nvim_lsp = fss.safe_require('cmp_nvim_lsp')
  if nvim_lsp_ok then
    cmp_nvim_lsp.update_capabilities(config.capabilities)
  end
  return config
end

return function()
  require('nvim-lsp-installer').setup({
    ensure_installed = vim.tbl_keys(fss.lsp.servers),
  })
  if vim.v.vim_did_enter == 1 then
    return
  end
  for name, config in pairs(fss.lsp.servers) do
    if config then
      require('lspconfig')[name].setup(fss.lsp.get_server_config(config))
    end
  end
end
