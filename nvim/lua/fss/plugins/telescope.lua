local M = {}

fss.telescope = {}

local function rectangular_border(opts)
  return vim.tbl_deep_extend('force', opts or {}, {
    borderchars = {
      prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
      results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
      preview = { '▔', '▕', '▁', '▏', '🭽', '🭾', '🭿', '🭼' },
    },
  })
end

---@param opts table?
---@return table
function fss.telescope.dropdown(opts)
  return require('telescope.themes').get_dropdown(rectangular_border(opts))
end

function fss.telescope.ivy(opts)
  return require('telescope.themes').get_ivy(
    vim.tbl_deep_extend('keep', opts or {}, {
      borderchars = {
        preview = {
          '▔',
          '▕',
          '▁',
          '▏',
          '🭽',
          '🭾',
          '🭿',
          '🭼',
        },
      },
    })
  )
end

function M.config()
  local telescope = require('telescope')
  local actions = require('telescope.actions')
  local layout_actions = require('telescope.actions.layout')
  local H = require('fss.highlights')
  local icons = fss.style.icons
  local fmt, fn = string.format, vim.fn

  fss.augroup('TelescopePreviews', {
    {
      event = 'User',
      pattern = 'TelescopePreviewerLoaded',
      command = 'setlocal number',
    },
  })

  H.plugin('telescope', {
    {
      TelescopePromptTitle = {
        bg = { from = 'PMenu' },
        fg = { from = 'Directory' },
        bold = true,
      },
    },
    {
      TelescopeResultsTitle = {
        bg = { from = 'PMenu' },
        fg = { from = 'Normal' },
        bold = true,
      },
    },
    {
      TelescopePreviewTitle = {
        bg = { from = 'PMenu' },
        fg = { from = 'Normal' },
        bold = true,
      },
    },
    {
      TelescopePreviewBorder = {
        fg = { from = 'FloatBorder' },
        bg = { from = 'PanelBackground' },
      },
    },
    { TelescopePreviewNormal = { link = 'PanelBackground' } },
    { TelescopePromptPrefix = { link = 'Statement' } },
    -- TelescopeBorder = { foreground = fss.style.palette.grey },
    { TelescopeMatching = { link = 'Title' } },
    { TelescopeTitle = { inherit = 'Normal', bold = true } },
    {
      TelescopeSelectionCaret = {
        fg = { from = 'Identifier' },
        bg = { from = 'TelescopeSelection' },
      },
    },
  })

  telescope.setup({
    defaults = {
      set_env = { ['TERM'] = vim.env.TERM },
      borderchars = {
        prompt = { ' ', '▕', '▁', '▏', '▏', '▕', '🭿', '🭼' },
        results = {
          '▔',
          '▕',
          '▁',
          '▏',
          '🭽',
          '🭾',
          '🭿',
          '🭼',
        },
        preview = {
          '▔',
          '▕',
          '▁',
          '▏',
          '🭽',
          '🭾',
          '🭿',
          '🭼',
        },
      },
      dynamic_preview_title = true,
      prompt_prefix = icons.misc.telescope .. ' ',
      selection_caret = icons.misc.chevron_right .. ' ',
      cycle_layout_list = {
        'flex',
        'horizontal',
        'vertical',
        'bottom_pane',
        'center',
      },
      mappings = {
        i = {
          ['<C-w>'] = actions.send_selected_to_qflist,
          ['<c-c>'] = function()
            vim.cmd('stopinsert!')
          end,
          ['<esc>'] = actions.close,
          ['<c-s>'] = actions.select_horizontal,
          ['<c-j>'] = actions.cycle_history_next,
          ['<c-k>'] = actions.cycle_history_prev,
          ['<c-e>'] = layout_actions.toggle_preview,
          ['<c-l>'] = layout_actions.cycle_layout_next,
          ['<c-/>'] = actions.which_key,
          ['<Tab>'] = actions.toggle_selection,
        },
        n = {
          ['<C-w>'] = actions.send_selected_to_qflist,
        },
      },
      file_ignore_patterns = {
        '%.jpg',
        '%.jpeg',
        '%.png',
        '%.otf',
        '%.ttf',
        '%.DS_Store',
        '^.git/',
        '^node_modules/',
        '^site-packages/',
      },
      path_display = { 'truncate' },
      winblend = 5,
      history = {
        path = vim.fn.stdpath('data') .. '/telescope_history.sqlite3',
      },
      layout_strategy = 'flex',
      layout_config = {
        horizontal = {
          preview_width = 0.55,
        },
        cursor = { -- TODO: I don't think this works but don't know why
          width = 0.4,
          height = function(self, _, max_lines)
            local results = #self.finder.results
            local PADDING = 4 -- this represents the size of the telescope window
            local LIMIT = math.floor(max_lines / 2)
            return (results <= (LIMIT - PADDING) and results + PADDING or LIMIT)
          end,
        },
      },
    },
    extensions = {
      fzf = {
        override_generic_sorter = true,
        override_file_sorter = true,
      },
      frecency = {
        default_workspace = 'LSP',
        show_unindexed = false, -- Show all files or only those that have been indexed
        ignore_patterns = {
          '*.git/*',
          '*/tmp/*',
          '*node_modules/*',
          '*vendor/*',
        },
        workspaces = {
          conf = vim.env.DOTFILES,
          project = vim.env.PROJECTS_DIR,
        },
      },
    },
    pickers = {
      buffers = fss.telescope.dropdown({
        sort_mru = true,
        sort_lastused = true,
        show_all_buffers = true,
        ignore_current_buffer = true,
        previewer = false,
        mappings = {
          i = { ['<c-x>'] = 'delete_buffer' },
          n = { ['<c-x>'] = 'delete_buffer' },
        },
      }),
      oldfiles = fss.telescope.dropdown(),
      live_grep = fss.telescope.ivy({
        file_ignore_patterns = { '.git/', '%.svg', '%.lock' },
        max_results = 2000,
        on_input_filter_cb = function(prompt)
          -- AND operator for live_grep like how fzf handles spaces with wildcards in rg
          return { prompt = prompt:gsub('%s', '.*') }
        end,
      }),
      current_buffer_fuzzy_find = fss.telescope.dropdown({
        previewer = false,
        shorten_path = false,
      }),
      colorscheme = {
        enable_preview = true,
      },
      find_files = {
        hidden = true,
      },
      keymaps = fss.telescope.dropdown({
        layout_config = {
          height = 18,
          width = 0.5,
        },
      }),
      git_branches = fss.telescope.dropdown(),
      git_bcommits = {
        layout_config = {
          horizontal = {
            preview_width = 0.55,
          },
        },
      },
      git_commits = {
        layout_config = {
          horizontal = {
            preview_width = 0.55,
          },
        },
      },
      reloader = fss.telescope.dropdown(),
    },
  })

  local builtins = require('telescope.builtin')

  require('telescope').load_extension('projects')

  local function delta_opts(opts, is_buf)
    local previewers = require('telescope.previewers')
    local delta = previewers.new_termopen_previewer({
      get_command = function(entry)
        local args = {
          'git',
          '-c',
          'core.pager=delta',
          '-c',
          'delta.side-by-side=false',
          'diff',
          entry.value .. '^!',
        }
        if is_buf then
          vim.list_extend(args, { '--', entry.current_file })
        end
        return args
      end,
    })
    opts = opts or {}
    opts.previewer = {
      delta,
      previewers.git_commit_message.new(opts),
    }
    return opts
  end

  local function delta_git_commits(opts)
    builtins.git_commits(delta_opts(opts))
  end

  local function delta_git_bcommits(opts)
    builtins.git_bcommits(delta_opts(opts, true))
  end

  local function dotfiles()
    builtins.find_files({
      prompt_title = 'dotfiles',
      cwd = vim.g.dotfiles,
    })
  end

  local function pickers()
    builtins.builtin({ include_extensions = true })
  end

  local function find_files()
    builtins.find_files(fss.telescope.dropdown({
      previewer = false,
    }))
  end

  local function buffers()
    builtins.buffers()
  end

  local function live_grep()
    builtins.live_grep()
  end

  local function frecency()
    require('telescope').extensions.frecency.frecency(fss.telescope.dropdown({
      previewer = false,
    }))
  end

  local function find_near_files()
    -- TODO: find files from closest package.json
    local cwd = require('telescope.utils').buffer_dir()
    builtins.find_files({
      prompt_title = fmt('Searching %s', fn.fnamemodify(cwd, ':~:.')),
      cwd = cwd,
    })
  end

  local function notifications()
    telescope.extensions.notify.notify(fss.telescope.dropdown())
  end

  local function installed_plugins()
    builtins.find_files({
      prompt_title = 'Installed plugins',
      cwd = vim.fn.stdpath('data') .. '/site/pack/packer',
    })
  end

  local function project_files(opts)
    if not pcall(builtins.git_files, opts) then
      builtins.find_files(opts)
    end
  end

  fss.nnoremap('<c-p>', project_files, 'telescope: find files')
  fss.nnoremap('<leader>fa', pickers, 'builtins')
  fss.nnoremap(
    '<leader>fb',
    builtins.current_buffer_fuzzy_find,
    'current buffer fuzzy find'
  )
  fss.nnoremap('<leader>fN', notifications, 'notifications')
  fss.nnoremap('<leader>fvh', builtins.highlights, 'highlights')
  fss.nnoremap('<leader>fva', builtins.autocommands, 'autocommands')
  fss.nnoremap('<leader>fvo', builtins.vim_options, 'options')
  fss.nnoremap('<leader>fvk', builtins.keymaps, 'autocommands')
  fss.nnoremap(
    '<leader>fle',
    builtins.diagnostics,
    'telescope: workspace diagnostics'
  )
  fss.nnoremap(
    '<leader>fld',
    builtins.lsp_document_symbols,
    'telescope: document symbols'
  )
  fss.nnoremap(
    '<leader>fls',
    builtins.lsp_dynamic_workspace_symbols,
    'telescope: workspace symbols'
  )
  fss.nnoremap('<leader>fp', installed_plugins, 'plugins')
  fss.nnoremap('<leader>fr', builtins.resume, 'resume last picker')
  fss.nnoremap('<leader>f?', builtins.help_tags, 'help')
  fss.nnoremap('<leader>ff', find_files, 'find files')
  fss.nnoremap('<leader>fn', find_near_files, 'find near files')
  fss.nnoremap('<leader>fh', frecency, 'Most (f)recently used files')
  fss.nnoremap('<leader>fgb', builtins.git_branches, 'branches')
  fss.nnoremap('<leader>fgc', delta_git_commits, 'commits')
  fss.nnoremap('<leader>fgB', delta_git_bcommits, 'buffer commits')
  fss.nnoremap('<leader>fo', buffers, 'buffers')
  fss.nnoremap('<leader>fs', live_grep, 'live grep')
  fss.nnoremap('<leader>fd', dotfiles, 'dotfiles')
end

return M
