-- Language servers

local fn, fmt = vim.fn, string.format

-- This function allows reading a per project "settings.json" file in the `.vim` directory of the project.
---@param client table<string, any>
---@return boolean
local function on_init(client)
  local settings = client.workspace_folders[1].name .. '/.vim/settings.json'

  if fn.filereadable(settings) == 0 then
    return true
  end
  local ok, json = pcall(fn.readfile, settings)
  if not ok then
    return true
  end

  local overrides = vim.json.decode(table.concat(json, '\n'))

  for name, config in pairs(overrides) do
    if name == client.name then
      client.config = vim.tbl_deep_extend('force', client.config, config)
      client.notify('workspace/didChangeConfiguration')

      vim.schedule(function()
        local path = fn.fnamemodify(settings, ':~:.')
        local msg =
          fmt('loaded local settings for %s from %s', client.name, path)
        vim.notify_once(msg, 'info', { title = 'LSP Settings' })
      end)
    end
  end
  return true
end

require('typescript').setup({
  disable_commands = false,
  debug = false,
})

local servers = {
  -- graphql = true,
  -- tsserver = true,
  elixirls = true,
  jsonls = true,
  dockerls = true,
  terraformls = true,
  tailwindcss = true,
  bashls = true,
  vimls = true,
  cssls = function()
    return {
      settings = {
        css = {
          validate = true,
          lint = {
            unknownAtRules = 'ignore',
          },
        },
      },
    }
  end,
  eslint = true,
  yamlls = true,
  racket_langserver = true,
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
    local path = vim.split(package.path, ';')
    table.insert(path, 'lua/?.lua')
    table.insert(path, 'lua/?/init.lua')

    local plugins = ('%s/site/pack/packer'):format(fn.stdpath('data'))
    local emmy = ('%s/start/emmylua-nvim'):format(plugins)
    local plenary = ('%s/start/plenary.nvim'):format(plugins)
    local packer = ('%s/opt/packer.nvim'):format(plugins)

    return {
      settings = {
        Lua = {
          runtime = {
            path = path,
            version = 'LuaJIT',
          },
          format = { enable = false },
          diagnostics = {
            globals = {
              'vim',
              'describe',
              'it',
              'before_each',
              'after_each',
              'packer_plugins',
            },
          },
          completion = { keywordSnippet = 'Replace', callSnippet = 'Replace' },
          workspace = {
            library = { vim.env.VIMRUNTIME, emmy, packer, plenary },
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    }
  end,
}

---Get the configuration for a specific language server
---@param name string
---@return table<string, any>?
return function(name)
  local config = servers[name]
  if not config then
    return
  end
  local t = type(config)
  if t == 'boolean' then
    config = {}
  end
  if t == 'function' then
    config = config()
  end
  config.on_init = on_init
  config.capabilities = config.capabilities
    or vim.lsp.protocol.make_client_capabilities()
  config.capabilities.textDocument.foldingRange =
    { dynamicRegistration = false, lineFoldingOnly = true }
  local ok, cmp_nvim_lsp = fss.require('cmp_nvim_lsp')
  if ok then
    cmp_nvim_lsp.default_capabilities(config.capabilities)
  end
  return config
end
