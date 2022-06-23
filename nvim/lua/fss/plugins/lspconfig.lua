-- Language servers

fss.lsp = {}

local fn = vim.fn

function fss.lsp.on_init(client)
  local path = client.workspace_folders[1].name
  local config_path = path .. '/.vim/settings.json'
  if fn.filereadable(config_path) == 0 then
    return true
  end
  local ok, json = pcall(fn.readfile, config_path)
  if not ok then
    return
  end
  local overrides = vim.json.decode(table.concat(json, '\n'))
  for name, config in pairs(overrides) do
    if name == client.name then
      local original = client.config
      client.config = vim.tbl_deep_extend('force', original, config)
      client.notify('workspace/didChangeConfiguration')
    end
  end
  return true
end

return function()
  -- FIXME: prevent language servers from being reset because this causes errors
  -- with in flight requests. Eventually this should be improved or allowed and so
  -- this won't be necessary
  if vim.g.lsp_config_complete then
    return
  end

  vim.g.lsp_config_complete = true
  local servers = {
    tsserver = function()
      local ts_utils = require('nvim-lsp-ts-utils')
      return {
        init_options = ts_utils.init_options,
        on_attach = function(client, bufnr)
          ts_utils.setup({
            -- enable_import_on_completion = true,
            auto_inlay_hints = false,
          })
          ts_utils.setup_client(client)
          -- keymappings
          local opts = { silent = true }
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gS', ':TSLspOrganize<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gR', ':TSLspRenameFile<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gA', ':TSLspImportAll<CR>', opts)
        end,
      }
    end,
    tailwindcss = true,
    dockerls = true,
    elixirls = true,
    graphql = true,
    jsonls = true,
    bashls = true,
    vimls = true,
    terraformls = true,
    cssls = true,
    yamlls = true,
    sqls = function()
      return {
        root_dir = require('lspconfig').util.root_pattern('.git'),
        single_file_support = false,
        on_new_config = function(new_config, new_rootdir)
          table.insert(new_config.cmd, '-config')
          table.insert(new_config.cmd, new_rootdir .. '/.config.yaml')
        end,
      }
    end,
    sumneko_lua = function()
      --- @see https://gist.github.com/folke/fe5d28423ea5380929c3f7ce674c41d8
      local settings = {
        settings = {
          Lua = {
            format = { enable = false },
            diagnostics = {
              globals = { 'vim', 'describe', 'it', 'before_each', 'after_each', 'packer_plugins' },
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
        library = { plugins = { 'plenary.nvim', 'neotest' } },
        lspconfig = settings,
      })
    end,
  }

  for name, config in pairs(servers) do
    if config and type(config) == 'boolean' then
      config = {}
    elseif config and type(config) == 'function' then
      config = config()
    end
    if config then
      config.capabilities = config.capabilities or vim.lsp.protocol.make_client_capabilities()
      config.capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }
      local ok, cmp_nvim_lsp = fss.safe_require('cmp_nvim_lsp')
      if ok then
        cmp_nvim_lsp.update_capabilities(config.capabilities)
      end
      require('lspconfig')[name].setup(config)
    end
  end
end
