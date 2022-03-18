local M = {}

function M.setup()
  require('which-key').register({
    d = {
      name = '+debugger',
      b = 'dap: toggle breakpoint',
      B = 'dap: set breakpoint',
      c = 'dap: continue or start debugging',
      e = 'dap: step out',
      i = 'dap: step into',
      o = 'dap: step over',
      l = 'dap REPL: run last',
      t = 'dap REPL: toggle',
    },
  }, {
    prefix = '<localleader>',
  })
end

function M.config()
  local dap = require 'dap'
  local fn = vim.fn
  local icons = fss.style.icons

  fn.sign_define('DapBreakpoint', {
    icon = icons.misc.bug,
    texthl = '',
    linehl = '',
    numhl = '',
  })

  fn.sign_define('DapStopped', {
    icon = '🟢',
    texthl = '',
    linehl = '',
    numhl = '',
  })

  dap.configurations.lua = {
    {
      type = 'nlua',
      request = 'attach',
      name = 'Attach to running Neovim instance',
      host = function()
        local value = fn.input 'Host [default: 127.0.0.1]: '
        return value ~= '' and value or '127.0.0.1'
      end,
      port = function()
        local val = tonumber(fn.input 'Port: ')
        assert(val, 'Please provide a port number')
        return val
      end,
    },
  }

  dap.adapters.nlua = function(callback, config)
    callback { type = 'server', host = config.host, port = config.port }
  end

  dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = {
      os.getenv 'HOME' .. '/projects/vscode-node-debug2/out/src/nodeDebug.js',
    },
  }

  dap.configurations.javascript = {
    {
      name = 'Launch',
      type = 'node2',
      request = 'launch',
      program = '${file}',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
    },
    {
      -- For this to work you need to make sure the node process is started with the `--inspect` flag.
      name = 'Attach to process',
      type = 'node2',
      request = 'attach',
      processId = require('dap.utils').pick_process,
    },
  }

  -- DON'T automatically stop at exceptions
  -- dap.defaults.fallback.exception_breakpoints = {}
  -- NOTE: the window options can be set directly in this function
  fss.nnoremap('<localleader>dt', function()
    require('dap').repl.toggle()
  end)
  fss.nnoremap('<localleader>dc', function()
    require('dap').continue()
  end)
  fss.nnoremap('<localleader>de', function()
    require('dap').step_out()
  end)
  fss.nnoremap('<localleader>di', function()
    require('dap').step_into()
  end)
  fss.nnoremap('<localleader>do', function()
    require('dap').step_over()
  end)
  fss.nnoremap('<localleader>dl', function()
    require('dap').run_last()
  end)
  fss.nnoremap('<localleader>db', function()
    require('dap').toggle_breakpoint()
  end)
  fss.nnoremap('<localleader>dB', function()
    require('dap').set_breakpoint(fn.input 'Breakpoint condition: ')
  end)
end

return M
