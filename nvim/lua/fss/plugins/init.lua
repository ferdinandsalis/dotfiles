local utils = require('fss.utils.plugins')
local conf = utils.conf
local packer_notify = utils.packer_notify
local fn = vim.fn
local fmt = string.format

local PACKER_COMPILED_PATH = fmt(
  '%s/packer/packer_compiled.lua',
  fn.stdpath('cache')
)

-- Bootstrap packer
utils.bootstrap_packer()

-- cfilter plugin allows filtering down an existing quickfix list
vim.cmd.packadd({ 'cfilter', bang = true })

fss.require('impatient')

local packer = require('packer')
packer.startup({
  function(use)
    use({ 'wbthomason/packer.nvim', opt = true })

    -- TODO: this fixes a bug in neovim core that prevents "CursorHold" from working
    -- hopefully one day when this issue is fixed this can be removed
    -- @see: https://github.com/neovim/neovim/issues/12587
    use('antoinemadec/FixCursorHold.nvim')

    -- Utilities {{{1

    -- The library
    use('nvim-lua/plenary.nvim')

    use('kyazdani42/nvim-web-devicons')

    use({
      'ahmedkhalf/project.nvim',
      config = function()
        require('project_nvim').setup({
          silent_chdir = false,
          detection_methods = { 'pattern', 'lsp' },
          ignore_lsp = { 'null-ls' },
          patterns = { 'package.json', '.git' },
        })
      end,
    })

    -- Shows key infos
    use({
      'folke/which-key.nvim',
      config = conf('whichkey'),
    })

    -- Display notifications
    use({
      'rcarriga/nvim-notify',
      cond = utils.not_headless,
      config = conf('notify'),
    })

    -- Shows undo steps in a tree
    use({
      'mbbill/undotree',
      cmd = 'UndotreeToggle',
      setup = function()
        fss.nnoremap('<leader>u', '<cmd>UndotreeToggle<CR>', 'undotree: toggle')
      end,
      config = function()
        vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
        vim.g.undotree_SetFocusWhenToggle = 1
      end,
    })

    -- FIXME: https://github.com/L3MON4D3/LuaSnip/issues/129
    -- causes formatting bugs on save when update events are TextChanged{I}
    use({
      'L3MON4D3/LuaSnip',
      event = 'InsertEnter',
      module = 'luasnip',
      requires = 'rafamadriz/friendly-snippets',
      config = conf('luasnip'),
    })

    use({
      'glepnir/template.nvim',
      config = function()
        local temp = require('template')
        temp.temp_dir = ('%s/templates/'):format(vim.g.vim_dir)
      end,
    })

    -- A toggable terminal
    use({
      'akinsho/toggleterm.nvim',
      config = conf('toggleterm'),
    })

    -- Quit buffers
    use({
      'moll/vim-bbye',
      config = function()
        fss.nnoremap('<leader>qq', '<Cmd>Bwipeout<CR>', 'bbye: quit')
      end,
    })

    -- Show colors inline
    use({
      'norcalli/nvim-colorizer.lua',
      config = function()
        require('colorizer').setup({ 'lua', 'vim', 'kitty', 'conf' }, {
          RGB = false,
          mode = 'background',
        })
      end,
    })

    -- Cycle folds with backspace
    use({
      'jghauser/fold-cycle.nvim',
      config = function()
        require('fold-cycle').setup()
        fss.nnoremap('<BS>', function()
          require('fold-cycle').open()
        end)
      end,
    })

    -- Cycle number, casing, color codes, etc.
    use({
      'monaqa/dial.nvim',
      config = conf('dial'),
    })

    -- Autopairs for quotes and what not
    use({
      'windwp/nvim-autopairs',
      after = 'nvim-cmp',
      config = function()
        require('nvim-autopairs').setup({
          close_triple_quotes = true,
          check_ts = true,
          ts_config = {
            lua = { 'string' },
            javascript = { 'template_string' },
          },
          fast_wrap = {
            map = '<c-e>',
          },
        })
      end,
    })

    -- Close and update tags (e.g. HTML and React)
    use('windwp/nvim-ts-autotag')

    -- prevent select and visual mode from overwriting the clipboard
    use({
      'kevinhwang91/nvim-hclipboard',
      event = 'InsertCharPre',
      config = function()
        require('hclipboard').start()
      end,
    })

    use({ 'chentoast/marks.nvim', config = conf('marks') })

    use({
      'itchyny/vim-highlighturl',
      config = function()
        local H = require('fss.highlights')
        vim.g.highlighturl_guifg = H.get('URL', 'fg')
      end,
    })

    use({
      'rmagatti/auto-session',
      config = function()
        local data = vim.fn.stdpath('data')
        require('auto-session').setup({
          log_level = 'error',
          auto_session_root_dir = string.format('%s/session/auto/', data),
          auto_restore_enabled = not vim.startswith(
            vim.fn.getcwd(),
            vim.env.PROJECTS_DIR
          ),
          auto_session_suppress_dirs = {
            vim.fn.expand('~'),
            vim.fn.expand('~/Desktop/'),
          },
          auto_session_use_git_branch = false, -- This cause inconsistent results
        })
      end,
    })

    -- readline shortcuts
    use({
      'linty-org/readline.nvim',
      event = 'CmdlineEnter',
      config = function()
        local readline = require('readline')
        local map = vim.keymap.set
        map('!', '<M-f>', readline.forward_word)
        map('!', '<M-b>', readline.backward_word)
        map('!', '<C-a>', readline.beginning_of_line)
        map('!', '<C-e>', readline.end_of_line)
        map('!', '<M-d>', readline.kill_word)
        map('!', '<M-BS>', readline.backward_kill_word)
        map('!', '<C-w>', readline.unix_word_rubout)
        map('!', '<C-k>', readline.kill_line)
        map('!', '<C-u>', readline.backward_kill_line)
      end,
    })

    use({
      'anuvyklack/hydra.nvim',
      config = conf('hydra'),
    })

    -- Navigate between vim windows and kitty windows
    use({
      'knubie/vim-kitty-navigator',
      run = 'cp ./*.py ~/.config/kitty/',
    })

    use('tpope/vim-eunuch')

    use('tpope/vim-sleuth')

    use('tpope/vim-repeat')

    -- }}}
    -- Syntax {{{1

    -- Syntax highlighting
    use({
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = conf('treesitter'),
      requires = {
        {
          'nvim-treesitter/playground',
          cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
          setup = function()
            fss.nnoremap(
              '<leader>E',
              '<Cmd>TSHighlightCapturesUnderCursor<CR>',
              'treesitter: cursor highlight'
            )
          end,
        },
      },
    })

    -- Visually select regions
    use({
      'mfussenegger/nvim-treehopper',
      config = function()
        fss.augroup('TreehopperMaps', {
          {
            event = 'FileType',
            command = function(args)
              local langs =
                require('nvim-treesitter.parsers').available_parsers()
              if vim.tbl_contains(langs, vim.bo[args.buf].filetype) then
                fss.omap(
                  'u',
                  ":<C-U>lua require('tsht').nodes()<CR>",
                  { buffer = args.buf }
                )
                fss.vnoremap(
                  'u',
                  ":lua require('tsht').nodes()<CR>",
                  { buffer = args.buf }
                )
              end
            end,
          },
        })
      end,
    })

    use({ 'p00f/nvim-ts-rainbow' })

    use({ 'nvim-treesitter/nvim-treesitter-textobjects' })

    use({
      'nvim-treesitter/nvim-treesitter-context',
      config = function()
        local hl = require('fss.highlights')
        hl.plugin('treesitter-context', {
          { ContextBorder = { link = 'Dim' } },
          { TreesitterContext = { inherit = 'Normal' } },
          { TreesitterContextLineNumber = { inherit = 'LineNr' } },
        })
        require('treesitter-context').setup({
          multiline_threshold = 4,
          separator = { '─', 'ContextBorder' }, --[[alernatives: ▁ ─ ▄ ]]
          mode = 'topline',
        })
      end,
    })

    -- highlight arguments in function bodies
    use({
      'm-demare/hlargs.nvim',
      config = function()
        local H = require('fss.highlights')
        H.plugin('hlargs', {
          {
            Hlargs = {
              italic = true,
              bold = false,
              foreground = fss.style.palette.blue,
            },
          },
        })
        require('hlargs').setup({
          excluded_argnames = {
            declarations = { 'use', 'use_rocks', '_' },
            usages = {
              go = { '_' },
              lua = { 'self', 'use', 'use_rocks', '_' },
            },
          },
        })
      end,
    })

    -- Kitty syntax highlighting
    use('fladson/vim-kitty')

    -- Indentlines
    use({
      'lukas-reineke/indent-blankline.nvim',
      config = conf('indentline'),
    })
    -- Virtual Column
    use({
      'lukas-reineke/virt-column.nvim',
      config = function()
        require('fss.highlights').plugin('virt_column', {
          { VirtColumn = { bg = 'None', inherit = 'Dim' } },
        })
        require('virt-column').setup({ char = '▕' })
      end,
    })
    -- }}}
    -- Lsp & Completion {{{1

    -- Install Lsp's
    use({
      'williamboman/mason.nvim',
      event = 'BufRead',
      branch = 'main',
      requires = { 'nvim-lspconfig', 'williamboman/mason-lspconfig.nvim' },
      config = function()
        local get_config = require('fss.servers')
        require('mason').setup({ ui = { border = fss.style.current.border } })
        require('mason-lspconfig').setup({ automatic_installation = true })
        require('mason-lspconfig').setup_handlers({
          function(name)
            local config = get_config(name)
            if config then
              require('lspconfig')[name].setup(config)
            end
          end,
        })
      end,
    })

    use({
      'neovim/nvim-lspconfig',
      module_pattern = 'lspconfig.*',
      -- config = function()
      --   local get_config = require('fss.servers')
      --   require('lspconfig').ccls.setup(get_config('ccls'))
      -- end,
    })

    use({
      'smjonas/inc-rename.nvim',
      config = function()
        require('inc_rename').setup({
          hl_group = 'Visual',
        })
        fss.nnoremap('<leader>ri', function()
          require('inc_rename').rename({ default = vim.fn.expand('<cword>') })
        end, {
          expr = true,
          silent = false,
          desc = 'lsp: incremental rename',
        })
      end,
    })

    use({
      'lvimuser/lsp-inlayhints.nvim',
      config = function()
        require('lsp-inlayhints').setup({
          inlay_hints = {
            highlight = 'Comment',
          },
        })
      end,
    })

    use({
      'andrewferrier/textobj-diagnostic.nvim',
      config = function()
        require('textobj-diagnostic').setup()
      end,
    })

    -- Dim unused variables
    use({
      'zbirenbaum/neodim',
      config = function()
        require('neodim').setup({
          alpha = 0.45,
          hide = {
            underline = false,
          },
        })
      end,
    })

    use({
      'jose-elias-alvarez/null-ls.nvim',
      requires = { 'nvim-lua/plenary.nvim' },
      config = conf('null'),
    })

    use({
      'jose-elias-alvarez/typescript.nvim',
      config = function()
        fss.nnoremap(
          'gS',
          '<Cmd>TypeScriptOrganizeImports<CR>',
          'TypeScript: Sort imports'
        )
        fss.nnoremap(
          'gA',
          '<Cmd>TypeScriptAddMissingImports<CR>',
          'TypeScript: Add missing import'
        )
        fss.nnoremap(
          'gR',
          '<Cmd>TypeScriptRenameFile<CR>',
          'TypeScript: Rename file'
        )
        fss.nnoremap('gF', '<Cmd>TypeScriptFixAll<CR>', 'TypeScript: Fix all')
      end,
    })

    -- Shows function signature
    use({
      'ray-x/lsp_signature.nvim',
      opt = true,
      config = function()
        require('lsp_signature').setup({
          hint_enable = false,
          handler_opts = { border = fss.style.current.border },
        })
      end,
    })

    -- All about Completion
    use({
      'hrsh7th/nvim-cmp',
      module = 'cmp',
      config = conf('cmp'),
      requires = {
        { 'hrsh7th/cmp-nvim-lsp', module = 'cmp_nvim_lsp' },
        { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
        { 'f3fora/cmp-spell', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-emoji', after = 'nvim-cmp' },
        { 'dmitmel/cmp-cmdline-history', after = 'nvim-cmp' },
        {
          'petertriho/cmp-git',
          after = 'nvim-cmp',
          config = function()
            require('cmp_git').setup({
              filetypes = { 'gitcommit', 'NeogitCommitMessage' },
            })
          end,
        },
      },
    })

    -- Copilot
    use({
      'github/copilot.vim',
      config = conf('copilot'),
    })

    -- Use <Tab> to escape from pairs such as ""|''|() etc.
    use({
      'abecodes/tabout.nvim',
      wants = { 'nvim-treesitter' },
      after = { 'nvim-cmp' },
      config = function()
        require('tabout').setup({
          ignore_beginning = false,
          completion = false,
        })
      end,
    })

    --}}}
    -- Testing & Debugging {{{1
    use({
      'nvim-neotest/neotest',
      module = 'neotest',
      config = conf('neotest').config,
      setup = conf('neotest').setup,
      requires = {
        'rcarriga/neotest-plenary',
        'haydenmeade/neotest-jest',
        'rcarriga/neotest-vim-test',
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        'antoinemadec/FixCursorHold.nvim',
      },
    })

    use('folke/lua-dev.nvim')

    --}}}
    -- Text {{{1
    use({
      'numToStr/Comment.nvim',
      config = function()
        require('Comment').setup()
      end,
    })

    use({
      'kylechui/nvim-surround',
      config = function()
        require('nvim-surround').setup({
          move_cursor = false,
          keymaps = {
            visual = 's',
          },
        })
      end,
    })

    use('chaoren/vim-wordmotion')
    -- }}}
    -- Themes & UI {{{1

    use('sainnhe/everforest')
    use('EdenEast/nightfox.nvim')
    use('folke/tokyonight.nvim')

    use({
      'stevearc/dressing.nvim',
      after = 'telescope.nvim',
      config = conf('dressing'),
    })

    -- Explore the filesystem
    use({
      'nvim-neo-tree/neo-tree.nvim',
      branch = 'v2.x',
      requires = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons',
        'MunifTanjim/nui.nvim',
        {
          'mrbjarksen/neo-tree-diagnostics.nvim',
          module = 'neo-tree.sources.diagnostics',
        },
      },
      config = conf('neotree'),
    })

    -- Displays a bufferline at the top
    use({
      'akinsho/bufferline.nvim',
      config = conf('bufferline'),
      requires = 'nvim-web-devicons',
    })

    -- Find the cursor
    use({
      'danilamihailov/beacon.nvim',
      config = function()
        vim.g.beacon_size = 30
      end,
    })

    -- Smooth scrolling
    use({
      'declancm/cinnamon.nvim',
      config = function()
        require('cinnamon').setup({
          extra_keymaps = true,
          scroll_limit = 50,
          hide_cursor = true,
          always_scroll = true,
        })
        local map = vim.keymap.set
        map(
          { 'n', 'x' },
          '<ScrollWheelUp>',
          "<Cmd>lua Scroll('<ScrollWheelUp>')<CR>"
        )
        map(
          { 'n', 'x' },
          '<ScrollWheelDown>',
          "<Cmd>lua Scroll('<ScrollWheelDown>')<CR>"
        )
      end,
    })

    -- Scrollbars
    use({
      'lewis6991/satellite.nvim',
      enable = false,
      opt = true,
      config = function()
        require('satellite').setup({
          handlers = {
            marks = {
              enable = false,
            },
          },
          excluded_filetypes = {
            'packer',
            'neo-tree',
            'norg',
            'neo-tree-popup',
            'dapui_scopes',
            'dapui_stacks',
          },
        })
      end,
    })

    use({
      'SmiteshP/nvim-navic',
      requires = 'neovim/nvim-lspconfig',
      config = function()
        local s = fss.style
        local misc = s.icons.misc

        local icons = fss.map(function(icon)
          return icon
        end, s.current.lsp_icons)

        -- Note: this options makes it so that it silences error messages
        vim.g.navic_silence = true
        require('nvim-navic').setup({
          icons = icons,
          highlight = true,
          depth_limit_indicator = misc.ellipsis,
          separator = (' %s '):format(misc.arrow_right),
        })
      end,
    })

    use({
      'kevinhwang91/nvim-ufo',
      requires = 'kevinhwang91/promise-async',
      config = conf('ufo'),
    })

    --- }}}
    -- Git {{{1

    use({
      'lewis6991/gitsigns.nvim',
      event = 'BufRead',
      config = conf('gitsigns'),
    })

    use({
      'TimUntersberger/neogit',
      cmd = 'Neogit',
      keys = { '<localleader>gs', '<localleader>gl', '<localleader>gp' },
      requires = 'plenary.nvim',
      setup = conf('neogit').setup,
      config = conf('neogit').config,
    })

    use({
      'sindrets/diffview.nvim',
      requires = 'nvim-lua/plenary.nvim',
      cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
      module = 'diffview',
      setup = function()
        fss.nnoremap(
          '<localleader>gd',
          '<Cmd>DiffviewOpen<CR>',
          'diffview: diff HEAD'
        )
        fss.nnoremap(
          '<localleader>gh',
          '<Cmd>DiffviewFileHistory<CR>',
          'diffview: file history'
        )
      end,
      config = function()
        require('diffview').setup({
          default_args = {
            DiffviewFileHistory = { '%' },
          },
          hooks = {
            diff_buf_read = function()
              vim.opt_local.wrap = false
              vim.opt_local.list = false
              vim.opt_local.colorcolumn = ''
            end,
          },
          enhanced_diff_hl = true,
          keymaps = {
            view = { q = '<Cmd>DiffviewClose<CR>' },
            file_panel = { q = '<Cmd>DiffviewClose<CR>' },
            file_history_panel = { q = '<Cmd>DiffviewClose<CR>' },
          },
        })
      end,
    })

    -- }}}
    -- Quickfix {{{1
    use({
      'https://gitlab.com/yorickpeterse/nvim-pqf',
      event = 'BufReadPre',
      config = function()
        require('fss.highlights').plugin(
          'pqf',
          { { qfPosition = { link = 'Tag' } } }
        )
        require('pqf').setup({})
      end,
    })

    use({
      'kevinhwang91/nvim-bqf',
      ft = 'qf',
    })
    -- }}}
    -- Knowledge and task management {{{1
    use({
      'lukas-reineke/headlines.nvim',
      ft = { 'org', 'norg', 'markdown', 'yaml' },
    })
    -- }}}
    -- Profiling & Startup {{{1
    use('lewis6991/impatient.nvim')
    use({
      'dstein64/vim-startuptime',
      tag = '*',
      cmd = 'StartupTime',
      config = function()
        vim.g.startuptime_tries = 15
        vim.g.startuptime_exe_args = { '+let g:auto_session_enabled = 0' }
      end,
    })
    -- }}}
    -- Search & Discovery {{{1
    use({
      'nvim-telescope/telescope.nvim',
      branch = 'master',
      module_pattern = 'telescope.*',
      config = conf('telescope').config,
      event = 'CursorHold',
      requires = {
        {
          'natecraddock/telescope-zf-native.nvim',
          after = 'telescope.nvim',
          config = function()
            require('telescope').load_extension('zf-native')
          end,
        },
        {
          'nvim-telescope/telescope-smart-history.nvim',
          requires = { { 'tami5/sqlite.lua', module = 'sqlite' } },
          after = 'telescope.nvim',
          config = function()
            require('telescope').load_extension('smart_history')
          end,
        },
        { 'Zane-/howdoi.nvim' },
        { 'ilAYAli/scMRU.nvim', module = 'mru' },
      },
    })

    use({
      'phaazon/hop.nvim',
      tag = 'v2.*',
      keys = { { 'n', 's' }, 'f', 'F' },
      config = conf('hop'),
    })
    -- }}}
  end,

  log = { level = 'info' },

  config = {
    max_jobs = 30,
    compile_path = PACKER_COMPILED_PATH,
    display = {
      prompt_border = fss.style.current.border,
      open_cmd = 'silent topleft 65vnew',
    },
    git = {
      clone_timeout = 240,
    },
    profile = {
      enable = true,
      threshold = 1,
    },
  },
})

fss.command('PackerCompiledEdit', function()
  vim.cmd.edit(PACKER_COMPILED_PATH)
end)

fss.command('PackerCompiledDelete', function()
  vim.fn.delete(PACKER_COMPILED_PATH)
  packer_notify(fmt('Deleted %s', PACKER_COMPILED_PATH))
end)

if
  not vim.g.packer_compiled_loaded and vim.loop.fs_stat(PACKER_COMPILED_PATH)
then
  vim.cmd.source(PACKER_COMPILED_PATH)
  vim.g.packer_compiled_loaded = true
end

fss.nnoremap('<leader>ps', '<Cmd>PackerSync<CR>', 'packer: sync')
fss.nnoremap('<leader>pc', '<Cmd>PackerCompile<CR>', 'packer: compile')
fss.nnoremap('<leader>pC', '<Cmd>PackerClean<CR>', 'packer: clean')

fss.augroup('PackerSetupInit', {
  {
    event = 'BufWritePost',
    pattern = { '*/fss/plugins/*.lua' },
    desc = 'Packer setup and reload',
    command = function()
      vim.cmd.doautocmd('LspDetach')
      fss.invalidate('fss.plugins', true)
      packer.compile()
    end,
  },
  {
    event = 'User',
    pattern = 'PackerCompileDone',
    command = function()
      packer_notify('Compilation finished', 'info')
    end,
  },
})

-- vim:foldmethod=marker
