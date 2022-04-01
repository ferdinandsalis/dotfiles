return function()
  local telescope = require 'telescope'
  local actions = require 'telescope.actions'
  local layout_actions = require 'telescope.actions.layout'
  local themes = require 'telescope.themes'
  local icons = fss.style.icons

  local P = fss.style.palette
  local H = require 'fss.highlights'

  H.plugin(
    'telescope',
    { 'TelescopeMatching', { link = 'Title' } },
    { 'TelescopeBorder', { link = 'FloatBorder' } },
    { 'TelescopeNormal', { link = 'FloatNormal' } },
    { 'TelescopeResultsNormal', { link = 'FloatNormal' } },
    { 'TelescopePreviewNormal', { link = 'FloatNormal' } },
    { 'TelescopePromptPrefix', { link = 'Statement' } },
    {
      'TelescopeTitle',
      { inherit = 'Normal', background = P.bg_highlight, bold = true },
    },
    {
      'TelescopeSelectionCaret',
      {
        foreground = H.get_hl('Identifier', 'fg'),
        background = H.get_hl('TelescopeSelection', 'bg'),
      },
    }
  )

  local function get_border(opts)
    return vim.tbl_deep_extend('force', opts or {}, {
      borderchars = {
        { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
        prompt = { '─', '│', ' ', '│', '╭', '╮', '│', '│' },
        results = { '─', '│', '─', '│', '├', '┤', '╯', '╰' },
        preview = {
          '─',
          '│',
          '─',
          '│',
          '╭',
          '╮',
          '╯',
          '╰',
        },
      },
    })
  end

  ---@param opts table
  ---@return table
  local function dropdown(opts)
    return themes.get_dropdown(get_border(opts))
  end

  telescope.setup {
    defaults = {
      set_env = { ['TERM'] = vim.env.TERM },
      borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
      prompt_prefix = icons.misc.telescope .. ' ',
      selection_caret = icons.misc.double_chevron_right .. ' ',
      mappings = {
        i = {
          ['<C-q>'] = actions.send_selected_to_qflist,
          ['<C-c>'] = function()
            vim.cmd 'stopinsert!'
          end,
          ['<esc>'] = actions.close,
          ['<C-s>'] = actions.select_horizontal,
          ['<C-j>'] = actions.cycle_history_next,
          ['<C-k>'] = actions.cycle_history_prev,
          ['<C-e>'] = layout_actions.toggle_preview,
          ['<C-l>'] = layout_actions.cycle_layout_next,
        },
        n = {
          ['<C-q>'] = actions.send_selected_to_qflist,
        },
      },
      file_ignore_patterns = {
        '%.jpg',
        '%.jpeg',
        '%.png',
        '%.otf',
        '%.ttf',
        '%.DS_Store',
      },
      path_display = { 'truncate', 'absolute' },
      winblend = fss.style.float.blend,
      history = {
        path = vim.fn.stdpath 'data' .. '/telescope_history.sqlite3',
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
      buffers = dropdown {
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
      oldfiles = dropdown(),
      live_grep = {
        file_ignore_patterns = { '.git/' },
      },
      current_buffer_fuzzy_find = dropdown {
        previewer = false,
        shorten_path = false,
      },
      lsp_code_actions = {
        theme = 'cursor',
      },
      colorscheme = {
        enable_preview = true,
      },
      find_files = dropdown {
        hidden = true,
        previewer = false,
      },
      git_files = dropdown {
        previewer = false,
      },
      git_branches = dropdown(),
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
      reloader = dropdown(),
    },
  }

  --- NOTE: this must be required after setting up telescope
  --- otherwise the result will be cached without the updates
  --- from the setup call
  local builtins = require 'telescope.builtin'

  local function project_files(opts)
    if not pcall(builtins.git_files, opts) then
      builtins.find_files(opts)
    end
  end

  local function nvim_config()
    builtins.find_files {
      prompt_title = 'Nvim Config',
      cwd = vim.fn.stdpath 'config',
      file_ignore_patterns = { '.git/.*', 'dotbot/.*' },
    }
  end

  local function dotfiles()
    builtins.find_files {
      prompt_title = 'Dotfiles',
      cwd = vim.g.dotfiles,
    }
  end

  local function orgfiles()
    builtins.find_files {
      prompt_title = 'Neorg',
      cwd = vim.fn.expand '$SYNC_DIR/neorg',
    }
  end

  local function frecency()
    telescope.extensions.frecency.frecency(dropdown {
      winblend = 10,
      border = true,
      previewer = false,
      shorten_path = false,
    })
  end

  local function prs()
    telescope.extensions.gh.pull_request(dropdown())
  end

  local function gh_notifications()
    telescope.extensions.ghn.ghn(dropdown())
  end

  local function installed_plugins()
    require('telescope.builtin').find_files {
      cwd = vim.fn.stdpath 'data' .. '/site/pack/packer',
    }
  end

  require('which-key').register {
    ['<c-p>'] = { builtins.find_files, 'telescope: find files' },
    ['<leader>f'] = {
      name = '+telescope',
      a = { builtins.builtin, 'builtins' },
      b = { builtins.current_buffer_fuzzy_find, 'current buffer fuzzy find' },
      d = { dotfiles, 'dotfiles' },
      f = { builtins.find_files, 'find files' },
      p = { project_files, 'project files' },
      n = { gh_notifications, 'notifications' },
      g = {
        name = '+git',
        c = { builtins.git_commits, 'commits' },
        b = { builtins.git_branches, 'branches' },
        p = { prs, 'PRs' },
      },
      m = { builtins.man_pages, 'man pages' },
      h = { frecency, 'history' },
      c = { nvim_config, 'nvim config' },
      o = { builtins.buffers, 'buffers' },
      P = { installed_plugins, 'plugins' },
      O = { orgfiles, 'org files' },
      R = { builtins.reloader, 'module reloader' },
      r = { builtins.resume, 'resume last picker' },
      s = { builtins.live_grep, 'grep string' },
      ['?'] = { builtins.help_tags, 'help' },
    },
    ['<leader>c'] = {
      d = {
        builtins.lsp_workspace_diagnostics,
        'telescope: workspace diagnostics',
      },
      s = { builtins.lsp_document_symbols, 'telescope: document symbols' },
      w = {
        builtins.lsp_dynamic_workspace_symbols,
        'telescope: workspace symbols',
      },
    },
  }
end
