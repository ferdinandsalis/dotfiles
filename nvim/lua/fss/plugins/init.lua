local utils = require('fss.utils.plugins')

local conf = utils.conf
local packer_notify = utils.packer_notify
local fn = vim.fn
local fmt = string.format

local PACKER_COMPILED_PATH = fn.stdpath('cache') .. '/packer/packer_compiled.lua'

---Some plugins are not safe to be reloaded because their setup functions
---and are not idempotent. This wraps the setup calls of such plugins
---@param func fun()
function fss.block_reload(func)
  if vim.g.packer_compiled_loaded then
    return
  end
  func()
end

-----------------------------------------------------------------------------//
-- Bootstrap Packer {{{
-----------------------------------------------------------------------------//
utils.bootstrap_packer()
-----------------------------------------------------------------------------//}}}

-- cfilter plugin allows filter down an existing quickfix list
vim.cmd('packadd! cfilter')

fss.safe_require('impatient')

-- NOTE: luarocks install on every single PackerInstall https://github.com/wbthomason/packer.nvim/issues/180

local packer = require('packer')
--- NOTE "use" functions cannot call *upvalues* i.e. the functions
--- passed to setup or config etc. cannot reference aliased functions
--- or local variables
packer.startup({
  function(use, use_rocks)
    use({ 'wbthomason/packer.nvim', opt = true })

    -----------------------------------------------------------------------------//
    -- Core {{{
    -----------------------------------------------------------------------------//

    use_rocks('penlight')

    -- @see: https://github.com/neovim/neovim/issues/12587
    use('antoinemadec/FixCursorHold.nvim')

    -- Change the current working directory automatically
    use({
      'ahmedkhalf/project.nvim',
      disable = true,
      config = function()
        require('project_nvim').setup({
          ignore_lsp = { 'null-ls', 'jsonls', 'graphql' },
          silent_chdir = false,
        })
      end,
    })

    use({
      'nvim-telescope/telescope.nvim',
      cmd = 'Telescope',
      keys = { '<c-p>', '<leader>fo', '<leader>ff', '<leader>fs' },
      module_pattern = 'telescope.*',
      config = conf('telescope'),
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
          'nvim-telescope/telescope-frecency.nvim',
          after = 'telescope.nvim',
          requires = 'tami5/sqlite.lua',
        },
        {
          'nvim-telescope/telescope-smart-history.nvim',
          after = 'telescope.nvim',
          config = function()
            require('telescope').load_extension('smart_history')
          end,
        },
      },
    })

    use({
      'folke/which-key.nvim',
      config = conf('whichkey'),
    })

    use('nvim-lua/plenary.nvim')

    use('kyazdani42/nvim-web-devicons')

    use({ 'ilAYAli/scMRU.nvim', module = 'mru' })

    use({
      'vim-test/vim-test',
      cmd = { 'Test*' },
      keys = { '<localleader>tf', '<localleader>tn', '<localleader>ts' },
      setup = conf('vim-test').setup,
      config = conf('vim-test').config,
    })

    use({
      'rcarriga/vim-ultest',
      wants = { 'vim-test' },
      requires = { 'vim-test' },
      run = ':UpdateRemotePlugins',
      cmd = 'Ultest',
      event = { 'CursorHold *_test.*,*_spec.*,*.test.*' },
      setup = conf('vim-ultest').setup,
      config = conf('vim-ultest').config,
    })

    use({
      'rmagatti/auto-session',
      disable = false,
      config = function()
        require('auto-session').setup({
          log_level = 'error',
          auto_session_root_dir = ('%s/session/auto/'):format(vim.fn.stdpath('data')),
          auto_session_use_git_branch = false,
        })
      end,
    })

    use({
      'rmagatti/session-lens',
      after = 'telescope.nvim',
      config = function()
        local session_lens = require('session-lens')
        require('which-key').register({
          ['<leader>fS'] = {
            session_lens.search_session,
            'sessions',
          },
        })
      end,
    })

    use({
      'akinsho/toggleterm.nvim',
      local_path = 'personal',
      config = conf('toggleterm'),
    })

    use({
      'knubie/vim-kitty-navigator',
      run = 'cp ./*.py ~/.config/kitty/',
    })

    use({
      'SmiteshP/nvim-gps',
      requires = 'nvim-treesitter/nvim-treesitter',
      config = function()
        require('nvim-gps').setup({})
      end,
    })

    use({
      'tpope/vim-abolish',
      config = conf('vim-abolish'),
    })

    use({
      'tpope/vim-projectionist',
      config = conf('vim-projectionist'),
    })

    -- sets searchable path for filetypes like go so 'gf' works
    use('tpope/vim-apathy')

    use('tpope/vim-eunuch')

    use('tpope/vim-repeat')

    -- }}}
    -----------------------------------------------------------------------------//
    -- Language, Completion & Debugger {{{
    -----------------------------------------------------------------------------//

    use({
      'mfussenegger/nvim-dap',
      setup = conf('dap').setup,
      config = conf('dap').config,
      requires = {
        {
          'rcarriga/nvim-dap-ui',
          after = 'nvim-dap',
          config = function()
            require('dapui').setup()
            fss.nnoremap('<localleader>duc', function()
              require('dapui').close()
            end, 'dap-ui: close')
            fss.nnoremap('<localleader>dut', function()
              require('dapui').toggle()
            end, 'dap-ui: toggle')

            -- NOTE: this opens dap UI automatically when dap starts
            local dap = require('dap')
            dap.listeners.before.event_terminated['dapui_config'] = function()
              require('dapui').close()
            end
            dap.listeners.before.event_exited['dapui_config'] = function()
              require('dapui').close()
            end
          end,
        },
        {
          'theHamsta/nvim-dap-virtual-text',
          config = function()
            require('nvim-dap-virtual-text').setup({ all_frames = true })
          end,
        },
      },
    })

    use('folke/lua-dev.nvim')

    use({
      'williamboman/nvim-lsp-installer',
      requires = { { 'neovim/nvim-lspconfig', config = conf('lspconfig') } },
      config = function()
        vim.api.nvim_create_autocmd('Filetype', {
          pattern = 'lsp-installer',
          callback = function()
            vim.api.nvim_win_set_config(0, { border = fss.style.current.border })
          end,
        })
      end,
    })

    use({
      'lukas-reineke/lsp-format.nvim',
      config = function()
        require('lsp-format').setup({})
        fss.nnoremap('<leader>rd', '<Cmd>FormatToggle<CR>', 'lsp format: toggle')
      end,
    })

    use({ -- Shows a spinner for the lsp status
      'j-hui/fidget.nvim',
      config = function()
        require('fidget').setup({
          text = {
            spinner = 'moon',
          },
          sources = { -- Sources to configure
            ['null-ls'] = { -- Name of source
              ignore = true, -- Ignore notifications from this source
            },
          },
        })
      end,
    })

    use('jose-elias-alvarez/nvim-lsp-ts-utils')

    use({
      'kosayoda/nvim-lightbulb',
      disable = true,
      config = function()
        require('fss.highlights').plugin('lightbulb', {
          LightBulbFloatWin = { link = 'Normal' },
        })
        local lightbulb = require('nvim-lightbulb')
        lightbulb.setup({
          ignore = { 'null-ls' },
          sign = { enabled = true },
          float = { enabled = false, win_opts = { border = 'none' } },
        })
        fss.augroup('Lightbulb', {
          {
            event = { 'CursorHold', 'CursorHoldI' },
            command = function()
              lightbulb.update_lightbulb()
            end,
          },
        })
      end,
    })

    use({
      'jose-elias-alvarez/null-ls.nvim',
      run = function()
        utils.install('write-good', 'npm', 'install -g')
      end,
      requires = { 'nvim-lua/plenary.nvim' },
      config = conf('null-ls'),
    })

    use({
      'ray-x/lsp_signature.nvim',
      config = function()
        require('lsp_signature').setup({
          bind = true,
          fix_pos = false,
          auto_close_after = 15, -- close after 15 seconds
          hint_enable = false,
          handler_opts = { border = fss.style.current.border },
        })
      end,
    })

    use({
      'RRethy/vim-illuminate',
      config = function()
        vim.g.Illuminate_delay = 300
        vim.g.Illuminate_ftblacklist = {
          'neo-tree',
          'packer',
          'DiffviewFiles',
          'toggleterm',
          'help',
        }
      end,
    })

    use({
      'hrsh7th/nvim-cmp',
      module = 'cmp',
      event = 'InsertEnter',
      requires = {
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
        { 'f3fora/cmp-spell', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-calc', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
        { 'lukas-reineke/cmp-rg', after = 'nvim-cmp' },
        { 'uga-rosa/cmp-dictionary', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-emoji', after = 'nvim-cmp' },
        { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
        {
          'tzachar/cmp-fuzzy-path',
          after = 'cmp-path',
          requires = { 'hrsh7th/cmp-path', 'tzachar/fuzzy.nvim' },
        },
        {
          'petertriho/cmp-git',
          after = 'nvim-cmp',
          config = function()
            require('cmp_git').setup({
              filetypes = { 'gitcommit', 'NeogitCommitMessage' },
            })
          end,
        },
        {
          'tzachar/cmp-fuzzy-buffer',
          after = 'nvim-cmp',
          requires = { 'tzachar/fuzzy.nvim' },
        },
      },
      config = conf('cmp'),
    })

    use({
      'ThePrimeagen/refactoring.nvim',
      config = function()
        local refactoring = require('refactoring')
        refactoring.setup({
          prompt_func_return_type = {
            go = true,
          },
          prompt_func_param_type = {
            go = true,
          },
        })
        fss.vnoremap('<leader>rr', function()
          require('telescope').extensions.refactoring.refactors()
        end, 'refactor: select')
        fss.nnoremap('<leader>rp', function()
          refactoring.debug.printf()
        end, 'refactor: printf')
        fss.vnoremap('<leader>rv', function()
          refactoring.debug.print_var()
        end, 'refactor: printf')
        fss.nnoremap('<leader>rc', function()
          refactoring.debug.cleanup()
        end)
      end,
    })

    use({
      'AckslD/nvim-neoclip.lua',
      disable = true,
      config = function()
        require('neoclip').setup({
          enable_persistant_history = true,
          keys = {
            i = { select = '<c-p>', paste = '<CR>', paste_behind = '<c-k>' },
            n = { select = 'p', paste = '<CR>', paste_behind = 'P' },
          },
        })
        local function clip()
          require('telescope').extensions.neoclip.default(
            require('telescope.themes').get_dropdown()
          )
        end

        require('which-key').register({
          ['<localleader>p'] = { clip, 'neoclip: open yank history' },
        })
      end,
    })

    use({
      'L3MON4D3/LuaSnip',
      event = 'InsertEnter',
      module = 'luasnip',
      requires = 'rafamadriz/friendly-snippets',
      config = conf('luasnip'),
    })

    use({
      'folke/trouble.nvim',
      keys = { '<leader>ld' },
      cmd = { 'TroubleToggle' },
      setup = function()
        require('which-key').register({
          ['<leader>l'] = {
            d = 'trouble: toggle',
            r = 'trouble: lsp references',
          },
          ['[d'] = 'trouble: next item',
          [']d'] = 'trouble: previous item',
        })
      end,
      requires = 'nvim-web-devicons',
      config = conf('trouble'),
    })

    use({
      'narutoxy/dim.lua',
      disable = true,
      requires = {
        'nvim-treesitter/nvim-treesitter',
        'neovim/nvim-lspconfig',
      },
      config = function()
        require('dim').setup({
          disable_lsp_decorations = true,
        })
      end,
    })

    -- }}}
    -----------------------------------------------------------------------------//
    -- Syntax & Treesitter {{{
    -----------------------------------------------------------------------------//
    use({
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = conf('treesitter'),
      requires = {
        { 'p00f/nvim-ts-rainbow', after = 'nvim-treesitter' },
        {
          'nvim-treesitter/nvim-treesitter-textobjects',
          after = 'nvim-treesitter',
        },
        {
          'nvim-treesitter/playground',
          keys = '<leader>E',
          cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
          setup = function()
            require('which-key').register({
              ['<leader>E'] = {
                '<Cmd>TSHighlightCapturesUnderCursor<CR>',
                'treesitter: highlight cursor group',
              },
            })
          end,
        },
      },
    })
    use({
      'nvim-treesitter/nvim-treesitter-textobjects',
      requires = 'nvim-treesitter',
    })
    use('RRethy/nvim-treesitter-textsubjects')

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

    use({
      'mizlan/iswap.nvim',
      cmd = { 'ISwap', 'ISwapWith' },
      keys = '<localleader>sw',
      config = function()
        require('iswap').setup({})
        require('which-key').register({
          ['<localleader>sw'] = {
            '<Cmd>ISwapWith<CR>',
            'swap arguments,parameters etc.',
          },
        })
      end,
    })

    use({
      'mfussenegger/nvim-ts-hint-textobject',
      config = function()
        fss.omap('m', ":<C-U>lua require('tsht').nodes()<CR>")
        fss.xnoremap('m', ":'<'>lua require('tsht').nodes()<CR>")
      end,
    })

    use({
      'lewis6991/spellsitter.nvim',
      disable = true,
      config = function()
        require('spellsitter').setup({
          enable = true,
        })
      end,
    })

    use({
      'nvim-treesitter/nvim-treesitter-context',
      config = function()
        require('fss.highlights').plugin('treesitter-context', {
          TreesitterContext = { inherit = 'Normal' },
        })
        require('treesitter-context').setup()
      end,
    })

    use('windwp/nvim-ts-autotag')
    use('mtdl9/vim-log-highlighting')
    use('fladson/vim-kitty')
    use('slime-lang/vim-slime-syntax')
    use('plasticboy/vim-markdown')
    use('jparise/vim-graphql')

    use('sainnhe/everforest')
    use('folke/tokyonight.nvim')
    use('NTBBloodbath/doom-one.nvim')

    use({ 'psliwka/vim-dirtytalk', run = ':DirtytalkUpdate' })

    -- }}}
    --------------------------------------------------------------------------------
    -- Git {{{
    --------------------------------------------------------------------------------

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
      cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
      module = 'diffview',
      setup = function()
        fss.nnoremap('<localleader>gd', '<Cmd>DiffviewOpen<CR>', 'diffview: diff HEAD')
      end,
      config = function()
        require('diffview').setup({
          enhanced_diff_hl = true,
          key_bindings = {
            file_panel = { q = '<Cmd>DiffviewClose<CR>' },
            view = { q = '<Cmd>DiffviewClose<CR>' },
          },
        })
      end,
    })

    use({
      'lewis6991/gitsigns.nvim',
      config = conf('gitsigns'),
      requires = { 'nvim-lua/plenary.nvim' },
    })

    use({
      'akinsho/git-conflict.nvim',
      -- config = function()
      --   require('git-conflict').setup {
      --     disable_diagnostics = true,
      --   }
      -- end,
    })

    use({
      'pwntester/octo.nvim',
      cmd = 'Octo*',
      setup = function()
        require('which-key').register({
          O = {
            name = '+octo',
            l = {
              name = '+list',
              i = { '<Cmd>Octo issue list<CR>', 'issues' },
              p = { '<Cmd>Octo pr list<CR>', 'pull requests' },
            },
          },
        }, { prefix = '<leader>' })
        fss.augroup('OctoFT', {
          {
            event = 'FileType',
            pattern = 'octo',
            command = function()
              require('fss.highlights').clear_hl('OctoEditable')
              fss.nnoremap('q', '<Cmd>Bwipeout<CR>', { buffer = 0 })
            end,
          },
        })
      end,
      config = function()
        require('octo').setup()
      end,
    })

    use({
      'rlch/github-notifications.nvim',
      cond = function()
        return fss.executable('gh')
      end,
      requires = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    })

    ---}}}
    --------------------------------------------------------------------------------
    -- Utilites {{{
    --------------------------------------------------------------------------------
    use({
      'b0o/incline.nvim',
      config = conf('incline'),
    })

    use({
      'stevearc/dressing.nvim',
      -- NOTE: Defer loading till telescope is loaded
      -- this implicitly loads telescope so needs to be delayed
      after = 'telescope.nvim',
      config = conf('dressing'),
    })

    use({
      'moll/vim-bbye',
      setup = function()
        require('which-key').register({
          ['<leader>qq'] = { '<cmd>Bdelete!<cr>', 'delete buffer' },
        })
      end,
    })

    use({
      'lukas-reineke/indent-blankline.nvim',
      config = conf('indent-blankline'),
    })

    -- A better bufferline
    use({
      'akinsho/bufferline.nvim',
      config = conf('bufferline'),
      requires = 'kyazdani42/nvim-web-devicons',
    })

    -- Multiple cursors
    use({
      'mg979/vim-visual-multi',
      disable = false,
      config = function()
        vim.g.VM_highlight_matches = 'underline'
        vim.g.VM_theme = 'codedark'
        vim.g.VM_maps = {
          ['Find Under'] = '<C-e>',
          ['Find Subword Under'] = '<C-e>',
          ['Select Cursor Down'] = [[\j]],
          ['Select Cursor Up'] = [[\k]],
        }
      end,
    })

    use({
      'nvim-neo-tree/neo-tree.nvim',
      branch = 'v2.x',
      config = conf('neotree'),
      requires = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'kyazdani42/nvim-web-devicons',
        {
          's1n7ax/nvim-window-picker',
          tag = '1.*',
          config = conf('window-picker'),
        },
      },
    })

    use('MunifTanjim/nui.nvim')

    use({
      'petertriho/nvim-scrollbar',
      disable = true,
      config = conf('nvim-scrollbar'),
    })

    use({
      'lewis6991/satellite.nvim',
      disable = true,
      config = function()
        -- FIXME: this should be reported upstream at some point This plugin
        -- is not safe to reload due to repeated attempts to map already mapped keys
        fss.block_reload(function()
          require('satellite').setup({
            excluded_filetypes = { 'packer', 'neo-tree', 'neo-tree-popup' },
          })
        end)
      end,
    })

    use({
      'anuvyklack/pretty-fold.nvim',
      disable = false,
      requires = { 'anuvyklack/nvim-keymap-amend' },
      config = function()
        require('pretty-fold').setup({
          keep_indentation = true,
          fill_char = '━',
          sections = {
            left = {
              'content',
            },
            right = {
              ' ',
              'number_of_folded_lines',
              ': ',
              'percentage',
              ' ━━',
            },
          },
        })

        require('pretty-fold.preview').setup({
          key = 'h',
        })
      end,
    })

    use({
      'folke/zen-mode.nvim',
      cmd = { 'ZenMode' },
      config = conf('zen-mode'),
    })

    use('folke/twilight.nvim')

    use({
      'iamcco/markdown-preview.nvim',
      run = function()
        vim.fn['mkdp#util#install']()
      end,
      ft = { 'markdown' },
      config = function()
        vim.g.mkdp_auto_start = 0
        vim.g.mkdp_auto_close = 1
      end,
    })

    -- resize windows via hjkl
    use({
      'simeji/winresizer',
      setup = function()
        vim.g.winresizer_start_key = '<leader>wr'
      end,
    })

    use({
      'klen/nvim-config-local',
      config = function()
        require('config-local').setup({
          config_files = { '.localrc.lua', '.vimrc', '.vimrc.lua' },
        })
      end,
    })

    -- prevent select and visual mode from overwriting the clipboard
    use({
      'kevinhwang91/nvim-hclipboard',
      config = function()
        require('hclipboard').start()
      end,
    })

    use({
      'simrat39/symbols-outline.nvim',
      cmd = 'SymbolsOutline',
      setup = function()
        fss.nnoremap('<leader>lS', '<Cmd>SymbolsOutline<CR>', 'toggle: symbols outline')
        vim.g.symbols_outline = {
          border = fss.style.current.border,
          auto_preview = false,
        }
      end,
    })

    use({
      'folke/todo-comments.nvim',
      requires = 'nvim-lua/plenary.nvim',
      config = conf('todo-comments'),
    })

    use({
      'github/copilot.vim',
      config = conf('copilot'),
    })

    use({
      'RRethy/vim-hexokinase',
      disable = false,
      run = 'make hexokinase',
      config = function()
        vim.g.Hexokinase_highlighters = { 'virtual' }
        vim.g.Hexokinase_optInPatterns = {
          'full_hex',
          'triple_hex',
          'rgb',
          'rgba',
          'hsl',
          'hsla',
        }
        vim.g.Hexokinase_ftEnabled = {
          'css',
          'html',
          'lua',
          'javascript',
          'typescript',
          'javascriptreact',
          'typescriptreact',
          'markdown',
          'sh',
          'json',
          'toml',
          'yaml',
        }
      end,
    })

    use({
      'norcalli/nvim-colorizer.lua',
      disable = true,
      config = function()
        require('colorizer').setup({ '*' }, {
          RGB = false,
          mode = 'background',
        })
      end,
    })

    -----------------------------------------------------------------------------//
    -- Quickfix
    -----------------------------------------------------------------------------//
    use({
      'yorickpeterse/nvim-pqf',
      event = 'BufReadPre',
      config = function()
        local h = require('fss.highlights')
        h.plugin('NvimPQF', {
          qfPosition = { link = 'Tag' },
        })
        require('pqf').setup({})
      end,
    })

    use({
      'kevinhwang91/nvim-bqf',
      config = function()
        local P = fss.style.palette
        local h = require('fss.highlights')
        h.plugin('nvim-bqf', {
          BqfPreviewBorder = {
            foreground = P.bg_popup,
            background = P.bg_popup,
          },
          BqfPreviewFloat = { background = P.bg_popup },
        })
      end,
    })

    ---}}}
    --------------------------------------------------------------------------------
    -- Search Tools {{{
    --------------------------------------------------------------------------------

    use({
      'phaazon/hop.nvim',
      keys = { { 'n', 's' }, 'f', 'F' },
      config = conf('hop'),
    })
    -- use 'ggandor/lightspeed.nvim'

    ---}}}
    --------------------------------------------------------------------------------
    -- Editing {{{
    --------------------------------------------------------------------------------

    use({ 'junegunn/vim-easy-align', cmd = 'EasyAlign' })

    use({
      'mbbill/undotree',
      cmd = 'UndotreeToggle',
      keys = '<leader>u',
      config = function()
        vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
        vim.g.undotree_SetFocusWhenToggle = 1
        require('which-key').register({
          ['<leader>u'] = 'undotree: toggle',
        })
      end,
    })

    use({ -- NOTE: alternative: 'karb94/neoscroll.nvim'
      'declancm/cinnamon.nvim',
      config = function()
        require('cinnamon').setup({
          extra_keymaps = true,
          extended_keymaps = true,
          scroll_limit = 50,
        })
      end,
    })

    use({
      'karb94/neoscroll.nvim',
      config = function()
        require('neoscroll').setup({
          mappings = {
            '<C-u>',
            '<C-d>',
            '<C-b>',
            '<C-f>',
            '<C-y>',
            'zt',
            'zz',
            'zb',
          },
          stop_eof = false,
          hide_cursor = true,
        })
      end,
    })

    use({
      'itchyny/vim-highlighturl',
      config = function()
        vim.g.highlighturl_guifg = require('fss.highlights').get_hl('Keyword', 'fg')
      end,
    })

    use({
      'rcarriga/nvim-notify',
      cond = utils.not_headless,
      config = conf('nvim-notify'),
    })

    use({
      'mfussenegger/nvim-treehopper',
      config = function()
        fss.omap('m', ":<C-U>lua require('tsht').nodes()<CR>")
        fss.vnoremap('m', ":lua require('tsht').nodes()<CR>")
      end,
    })

    use({
      'windwp/nvim-autopairs',
      after = 'nvim-cmp',
      config = function()
        require('nvim-autopairs').setup({
          close_triple_quotes = true,
          check_ts = true,
          ts_config = {
            lua = { 'string' },
            dart = { 'string' },
            javascript = { 'template_string' },
          },
          fast_wrap = {
            map = '<c-e>',
          },
        })
      end,
    })

    -- provides mappings to easily delete, change and add such surroundings in pairs
    use({
      'tpope/vim-surround',
      config = function()
        fss.xmap('s', '<Plug>VSurround')
        fss.xmap('s', '<Plug>VSurround')
      end,
    })

    use({
      'Matt-A-Bennett/vim-surround-funk',
      config = conf('vim-surround-funk'),
    })

    use({
      'AckslD/nvim-trevJ.lua',
      module = 'trevj',
      setup = function()
        fss.nnoremap('gS', function()
          require('trevj').format_at_cursor()
        end, { desc = 'splitjoin: split' })
      end,
      config = function()
        require('trevj').setup()
      end,
    })

    -- Commenting made better
    use({
      'numToStr/Comment.nvim',
      config = function()
        require('Comment').setup()
      end,
    })

    -- Provide new operator motions to perform substitutions and exchange
    use({
      'gbprod/substitute.nvim',
      config = conf('substitute'),
    })

    -- Provides Line wise and delimiter sorting via :Sort
    use('sQVe/sort.nvim')

    -- More useful word motions for  vim
    use('chaoren/vim-wordmotion')

    -- Cycle open and closed folds
    use({
      'jghauser/fold-cycle.nvim',
      config = function()
        require('fold-cycle').setup()
        fss.nnoremap('<BS>', function()
          require('fold-cycle').open()
        end)
      end,
    })

    -- Increment/decrement things
    use({
      'monaqa/dial.nvim',
      config = conf('dial'),
    })

    -- See the cursor jump
    use({
      'danilamihailov/beacon.nvim',
      config = function()
        local P = fss.style.palette
        require('fss.highlights').plugin('beacon', {
          Beacon = { background = P.comment },
        })
        vim.g.beacon_size = 30
      end,
    })

    -- Display marks in the sign column
    use({
      'chentoast/marks.nvim',
      config = conf('marks'),
    })

    -- Highlight ranges you enter in the command line
    use({
      'winston0410/range-highlight.nvim',
      disable = true,
      config = function()
        require('range-highlight').setup()
      end,
    })

    ---}}}
    --------------------------------------------------------------------------------
    -- Knowledge and task management {{{
    --------------------------------------------------------------------------------

    -- Getting things done and notes
    use({
      'vhyrro/neorg',
      requires = { 'vhyrro/neorg-telescope', 'max397574/neorg-kanban' },
      config = conf('neorg'),
    })

    -- This plugin adds horizontal highlights for text filetypes
    use({
      'lukas-reineke/headlines.nvim',
      setup = conf('headlines').setup,
      config = conf('headlines').config,
    })

    -- Replaces the asterisks in org syntax with unicode characters
    use({
      'akinsho/org-bullets.nvim',
      disable = true,
      config = function()
        require('org-bullets').setup()
      end,
    })

    ---}}}
    --------------------------------------------------------------------------------
    -- Profiling & Startup {{{
    --------------------------------------------------------------------------------

    -- NOTE: this plugin will be redundant once https://github.com/neovim/neovim/pull/15436 is merged
    use('lewis6991/impatient.nvim')

    use({
      'dstein64/vim-startuptime',
      cmd = 'StartupTime',
      config = function()
        vim.g.startuptime_tries = 15
        vim.g.startuptime_exe_args = { '+let g:auto_session_enabled = 0' }
      end,
    })
    ---}}}
    --------------------------------------------------------------------------------
  end,
  log = { level = 'debug' },
  config = {
    max_jobs = 50,
    compile_path = PACKER_COMPILED_PATH,
    display = {
      prompt_border = fss.style.current.border,
      open_cmd = 'silent topleft 65vnew',
    },
    profile = {
      enable = true,
      threshold = 1,
    },
  },
})

fss.command('PackerCompiledEdit', function()
  vim.cmd(fmt('edit %s', PACKER_COMPILED_PATH))
end)

fss.command('PackerCompiledDelete', function()
  vim.fn.delete(PACKER_COMPILED_PATH)
  packer_notify(fmt('Deleted %s', PACKER_COMPILED_PATH))
end)

if not vim.g.packer_compiled_loaded then
  fss.source(PACKER_COMPILED_PATH)
  vim.g.packer_compiled_loaded = true
end

local function open_plugin_url()
  fss.nnoremap('gf', function()
    local repo = fn.expand('<cfile>')
    if repo:match('https://') then
      return vim.cmd('norm gx')
    end
    if not repo or #vim.split(repo, '/') ~= 2 then
      return vim.cmd('norm! gf')
    end
    local url = fmt('https://www.github.com/%s', repo)
    fn.jobstart(fmt('%s %s', vim.g.open_command, url))
    vim.notify(fmt('Opening %s at %s', repo, url))
  end)
end

fss.augroup('PackerSetupInit', {
  {
    event = 'BufWritePost',
    description = 'Packer setup and reload',
    pattern = '*/fss/plugins/*.lua',
    command = function()
      fss.invalidate('fss.plugins', true)
      packer.compile()
    end,
  },
  -- {
  --   event = 'User',
  --   pattern = 'PackerCompileDone',
  --   description = 'Packer compilation done',
  --   command = function()
  --     vim.notify('Packer compile complete', nil, { title = 'Packer' })
  --   end,
  -- },
  {
    event = 'BufEnter',
    buffer = 0,
    description = 'Open a repository from an authorname/repository string',
    command = open_plugin_url,
  },
})

fss.nnoremap('<leader>ps', [[<Cmd>PackerSync<CR>]])
fss.nnoremap('<leader>pc', [[<Cmd>PackerClean<CR>]])

-- vim:foldmethod=marker
