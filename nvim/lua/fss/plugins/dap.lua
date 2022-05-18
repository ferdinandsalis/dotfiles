local M = {}

function M.setup()
  local fn = vim.fn
  local function repl_toggle()
    require('dap').repl.toggle(nil, 'botright split')
  end
  local function continue()
    require('dap').continue()
  end
  local function step_out()
    require('dap').step_out()
  end
  local function step_into()
    require('dap').step_into()
  end
  local function step_over()
    require('dap').step_over()
  end
  local function run_last()
    require('dap').run_last()
  end
  local function toggle_breakpoint()
    require('dap').toggle_breakpoint()
  end
  local function set_breakpoint()
    require('dap').set_breakpoint(fn.input('Breakpoint condition: '))
  end

  require('which-key').register({
    d = {
      name = '+debugger',
      b = { toggle_breakpoint, 'dap: toggle breakpoint' },
      B = { set_breakpoint, 'dap: set breakpoint' },
      c = { continue, 'dap: continue or start debugging' },
      e = { step_out, 'dap: step out' },
      i = { step_into, 'dap: step into' },
      o = { step_over, 'dap: step over' },
      l = { run_last, 'dap REPL: run last' },
      t = { repl_toggle, 'dap REPL: toggle' },
    },
  }, {
    prefix = '<localleader>',
  })
end

function M.config()
  local dap = require('dap')
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
        local value = fn.input('Host [default: 127.0.0.1]: ')
        return value ~= '' and value or '127.0.0.1'
      end,
      port = function()
        local val = tonumber(fn.input('Port: '))
        assert(val, 'Please provide a port number')
        return val
      end,
    },
  }

  dap.adapters.nlua = function(callback, config)
    callback({ type = 'server', host = config.host, port = config.port })
  end

  dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = {
      os.getenv('HOME') .. '/projects/vscode-node-debug2/out/src/nodeDebug.js',
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
end

return M
