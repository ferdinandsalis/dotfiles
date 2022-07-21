local M = {}

function M.setup()
  local function open() require('neotest').output.open({ enter = true, short = false }) end
  local function run_file() require('neotest').run.run(vim.fn.expand('%')) end
  local function nearest() require('neotest').run.run() end
  local function next_failed() require('neotest').jump.prev({ status = 'failed' }) end
  local function prev_failed() require('neotest').jump.next({ status = 'failed' }) end
  local function toggle_summary() require('neotest').summary.toggle() end
  fss.nnoremap('<localleader>ts', toggle_summary, 'neotest: run suite')
  fss.nnoremap('<localleader>to', open, 'neotest: output')
  fss.nnoremap('<localleader>tn', nearest, 'neotest: run')
  fss.nnoremap('<localleader>tf', run_file, 'neotest: run file')
  fss.nnoremap('[n', next_failed, 'jump to next failed test')
  fss.nnoremap(']n', prev_failed, 'jump to previous failed test')
end

function M.config()
  require('neotest').setup({
    diagnostic = {
      enabled = false,
    },
    icons = {
      running = fss.style.icons.misc.clock,
    },
    floating = {
      border = fss.style.current.border,
    },
    adapters = {
      require('neotest-jest')({
        jestCommand = 'npm test --',
      }),
      require('neotest-vim-test')({
        ignore_file_types = { 'lua' },
      }),
    },
  })
end

return M
