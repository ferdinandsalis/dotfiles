local packer = require('packer')
local utils = require('fss.utils.plugins')
local fn = vim.fn

--local PACKER_COMPILED_PATH = fn.stdpath('cache') .. '/packer/packer_compiled.lua'

-- cfilter plugin allows filtering down an existing quickfix list
vim.cmd('packadd! cfilter')

fss.safe_require('impatient')

packer.startup({
  function(use, use_rocks)
    use('wbthomason/packer.nvim')

    use_rocks('penlight')

    -- TODO: this fixes a bug in neovim core that prevents "CursorHold" from working
    -- hopefully one day when this issue is fixed this can be removed
    -- @see: https://github.com/neovim/neovim/issues/12587
    use('antoinemadec/FixCursorHold.nvim')

    -- The library
    use('nvim-lua/plenary.nvim')

    use('kyazdani42/nvim-web-devicons')

    -- Shows key infos
    use({
      'folke/which-key.nvim',
      config = utils.conf('whichkey')
    })

    -- Quit buffers
    use({
      'moll/vim-bbye',
      config = function()
        fss.nnoremap('<leader>qq', '<Cmd>Bwipeout<CR>', 'bbye: quit')
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

    -- Automatically save and restores sessions
    use({
      'rmagatti/auto-session',
      config = function()
        require('auto-session').setup {
          auto_session_root_dir = ('%s/session/auto/'):format(
            vim.fn.stdpath 'data'
          ),
        }
      end,
    })

    -- Navigate between vim windows and kitty windows
    use({
      'knubie/vim-kitty-navigator',
      run = 'cp ./*.py ~/.config/kitty/',
    })

    -- Syntax {{{1

    -- Coloring
    use({
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = utils.conf('treesitter'),
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

    -- Indent lines
    use({
      'lukas-reineke/indent-blankline.nvim',
      config = utils.conf('indentline'),
    })

    -- Lsp & Completion {{{1

    -- Install Lsp's
    use({
      {
        'williamboman/nvim-lsp-installer',
        event = 'BufRead',
        config = function()
          require('nvim-lsp-installer').setup({
            automatic_installation = true,
            ui = { border = fss.style.current.border },
          })
        end,
      },
      {
        'neovim/nvim-lspconfig',
        after = 'nvim-lsp-installer',
        config = utils.conf('lspconfig'),
      },
    })

    use({
      'smjonas/inc-rename.nvim',
      config = function()
        require('inc_rename').setup({
          hl_group = 'Visual',
        })
        fss.nnoremap('<leader>ri', function()
          return ':IncRename ' .. vim.fn.expand('<cword>')
        end, {
          expr = true,
          silent = false,
          desc = 'lsp: incremental rename',
        })
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

    -- Shows function signature
    use({
      'ray-x/lsp_signature.nvim',
      config = function()
        require('lsp_signature').setup({
          bind = true,
          fix_pos = false,
          auto_close_after = 15, -- close after 15 seconds
          hint_enable = false,
          handler_opts = { border = fss.style.current.border },
          toggle_key = '<C-K>',
          select_signature_key = '<M-N>',
        })
      end,
    })

    -- All about Completion
    use({
      'hrsh7th/nvim-cmp',
      module = 'cmp',
      event = 'InsertEnter',
      config = utils.conf('cmp'),
      requires = {
        { 'hrsh7th/cmp-nvim-lsp', after = 'nvim-lspconfig' },
        { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
        { 'f3fora/cmp-spell', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
        { 'uga-rosa/cmp-dictionary', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-emoji', after = 'nvim-cmp' },
        { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
        { 'dmitmel/cmp-cmdline-history', after = 'nvim-cmp' },
        {
          'petertriho/cmp-git',
          after = 'nvim-cmp',
          config = function()
            require('cmp_git').setup({ filetypes = { 'gitcommit', 'NeogitCommitMessage' } })
          end,
        },
      },
    })

    -- Use <Tab> to escape from pairs such as ""|''|() etc.
    use({
      'abecodes/tabout.nvim',
      wants = { 'nvim-treesitter' },
      after = { 'nvim-cmp' },
      config = function()
        require('tabout').setup({
          completion = false,
          ignore_beginning = false,
        })
      end,
    })

    --}}}
    -- Testing & Debugging {{{1

    use('folke/lua-dev.nvim')

    --}}}
    -- Text Object {{{1
    use({
      'numToStr/Comment.nvim',
      config = function()
        require('Comment').setup()
      end,
    })

    use({
      'tpope/vim-surround',
      config = function()
        fss.xmap('s', '<Plug>VSurround')
        fss.xmap('s', '<Plug>VSurround')
      end,
    })
    -- }}}
    -- Themes & UI {{{1
    use('folke/tokyonight.nvim')

    -- Explore the filesystem
    use({
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v2.x",
      requires = {
        "nvim-lua/plenary.nvim",
        "kyazdani42/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
     config = utils.conf('neotree')
    })

    -- Displays a bufferline at the top
    use({
      'akinsho/bufferline.nvim',
      config = utils.conf('bufferline'),
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
          default_delay = 5,
        })
      end,
    })

    -- Scrollbars
    use({
      'lewis6991/satellite.nvim',
      config = function()
        require('satellite').setup({
          handlers = {
            gitsigns = {
              enable = false,
            },
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
      config = function()
        --local hl = require('as.highlights')
        --local bg = hl.alter_color(hl.get('Normal', 'bg'), -7)
        --hl.plugin('ufo', { Folded = { bold = false, italic = false, bg = bg } })
        vim.opt.foldlevelstart = 2
        vim.opt.foldlevel = 2
        vim.opt.sessionoptions:append('folds')
        local ufo = require('ufo')
        ufo.setup({ open_fold_hl_timeout = 0 })
        fss.nnoremap('zR', ufo.openAllFolds, 'open all folds')
        fss.nnoremap('zM', ufo.closeAllFolds, 'close all folds')
      end,
    })

    --- }}}
    -- Git {{{1

    use({
      'lewis6991/gitsigns.nvim',
      event = 'CursorHold',
      config = utils.conf('gitsigns')
    })

    use({
      'TimUntersberger/neogit',
      cmd = 'Neogit',
      keys = { '<localleader>gs', '<localleader>gl', '<localleader>gp' },
      requires = 'plenary.nvim',
      setup = utils.conf('neogit').setup,
      config = utils.conf('neogit').config,
    })

    use({
      'sindrets/diffview.nvim',
      cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
      module = 'diffview',
      setup = function()
        utils.fss.nnoremap('<localleader>gd', '<Cmd>DiffviewOpen<CR>', 'diffview: diff HEAD')
        utils.fss.nnoremap('<localleader>gh', '<Cmd>DiffviewFileHistory<CR>', 'diffview: file history')
      end,
      config = function()
        require('diffview').setup({
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
    -- Profiling & Startup {{{1
    use('lewis6991/impatient.nvim')
    use({
      'dstein64/vim-startuptime',
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
      cmd = 'Telescope',
      module_pattern = 'telescope.*',
      config = utils.conf('telescope').config,
      event = 'CursorHold',
      requires = {
        {
          'nvim-telescope/telescope-fzf-native.nvim',
          run = 'make',
          after = 'telescope.nvim',
          config = function()
            require('telescope').load_extension('fzf')
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
  end,

  log = { level = 'info' },

  config = {
    max_jobs = 30,
    --compile_path = PACKER_COMPILED_PATH,
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

fss.nnoremap('<leader>ps', '<Cmd>PackerSync<CR>', 'packer: sync')

-- vim:foldmethod=marker
