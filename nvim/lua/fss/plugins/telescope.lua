return function()
  local telescope = require 'telescope'
  local actions = require 'telescope.actions'
  local themes = require 'telescope.themes'

  local H = require 'fss.highlights'
  local normal_bg = H.get_hl('Normal', 'bg')
  local comment_fg = H.get_hl('Comment', 'fg')
  H.plugin(
    'telescope',
    { 'TelescopePathSeparator', { link = 'Directory' } },
    { 'TelescopeQueryFilter', { link = 'IncSearch' } },
    { 'TelescopeBorder', { guibg = normal_bg, guifg = comment_fg } },
    { 'TelescopeSelectionCaret', { guifg = H.get_hl('Identifier', 'fg'), guibg = H.get_hl('TelescopeSelection', 'bg'), }, }
  )

  telescope.setup {
    defaults = {
      set_env = { ['TERM'] = vim.env.TERM },
      prompt_prefix = ' ',
      selection_caret = '» ',
      mappings = {
        i = {
          ['<c-c>'] = function()
            vim.cmd 'stopinsert!'
          end,
          ['<esc>'] = actions.close,
          ['<c-s>'] = actions.select_horizontal,
          ['<c-j>'] = actions.cycle_history_next,
          ['<c-k>'] = actions.cycle_history_prev,
        },
      },
      file_ignore_patterns = { '%.jpg', '%.jpeg', '%.png', '%.otf', '%.ttf' },
      layout_strategy = 'flex',
      winblend = 10,
      layout_config = {
        horizontal = {
          preview_width = 0.45,
        },
      },
      history = {
        path = '~/.local/share/nvim/telescope_history.sqlite3',
      },
    },
    extensions = {
      frecency = {
        workspaces = {
          conf = vim.env.DOTFILES,
          project = vim.env.PROJECTS_DIR,
          wiki = vim.g.wiki_path,
        },
      },
      fzf = {
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
      },
    },
    pickers = {
      buffers = {
        sort_mru = true,
        sort_lastused = true,
        show_all_buffers = true,
        ignore_current_buffer = true,
        previewer = false,
        theme = 'dropdown',
        mappings = {
          i = { ['<c-x>'] = 'delete_buffer' },
          n = { ['<c-x>'] = 'delete_buffer' },
        },
      },
      oldfiles = {
        theme = 'dropdown',
      },
      live_grep = {
        file_ignore_patterns = { '.git/' },
      },
      lsp_code_actions = {
        theme = 'cursor',
      },
      colorscheme = {
        enable_preview = true,
      },
      find_files = {
        hidden = true,
      },
      git_branches = {
        theme = 'dropdown',
      },
      reloader = {
        theme = 'dropdown',
      },
    },
  }

  telescope.load_extension 'fzf'
  telescope.load_extension 'smart_history'

  --- NOTE: this must be required after setting up telescope
  --- otherwise the result will be cached without the updates
  --- from the setup call
  local builtins = require 'telescope.builtin'

  local function nvim_config()
    builtins.find_files {
      prompt_title = '~ nvim config ~',
      cwd = vim.g.vim_dir,
      file_ignore_patterns = { '.git/.*', 'dotbot/.*' },
    }
  end

  local function frecency()
    telescope.extensions.frecency.frecency(themes.get_dropdown {
      default_text = ':CWD:',
      winblend = 10,
      border = true,
      previewer = false,
      shorten_path = false,
    })
  end

  require('which-key').register({
    f = {
      name = '+telescope',
      a = { builtins.builtin, 'builtins' },
      g = {
        name = '+git',
        c = { builtins.git_commits, 'commits' },
        b = { builtins.git_branches, 'branches' },
      },
      m = { builtins.man_pages, 'man pages' },
      h = { frecency, 'history' },
      n = { nvim_config, 'nvim config' },
      r = { builtins.reloader, 'module reloader' },
      o = { builtins.buffers, 'buffers' },
      w = { builtins.lsp_dynamic_workspace_symbols, 'workspace symbols', silent = false },
      ['?'] = { builtins.help_tags, 'help' },
    },
    c = {
      d = { builtins.lsp_workspace_diagnostics, 'telescope: workspace diagnostics' },
    },
  }, {
    prefix = '<leader>',
  })
end
