local utils = require 'fss.utils.plugins'

local conf = utils.conf
local packer_notify = utils.packer_notify
local fn = vim.fn
local fmt = string.format

local PACKER_COMPILED_PATH = fn.stdpath 'cache' .. '/packer/packer_compiled.lua'

-----------------------------------------------------------------------------//
-- Bootstrap Packer {{{
-----------------------------------------------------------------------------//
utils.bootstrap_packer()
-----------------------------------------------------------------------------//}}}

-- cfilter plugin allows filter down an existing quickfix list
vim.cmd 'packadd! cfilter'

fss.safe_require 'impatient'

-- NOTE: luarocks install on every single PackerInstall https://github.com/wbthomason/packer.nvim/issues/180

require('packer').startup {
  function(use, use_rocks)
    use { 'wbthomason/packer.nvim', opt = true }

    -----------------------------------------------------------------------------//
    -- Core {{{
    -----------------------------------------------------------------------------//

    use_rocks 'penlight'

    use {
      'ahmedkhalf/project.nvim',
      disable = true,
      config = function()
        require('project_nvim').setup {
          ignore_lsp = { 'null-ls', 'jsonls', 'graphql' },
          silent_chdir = false,
        }
      end,
    }

    use {
      'nvim-telescope/telescope.nvim',
      cmd = 'Telescope',
      keys = { '<c-p>', '<leader>fo', '<leader>ff', '<leader>fs' },
      module_pattern = 'telescope.*',
      config = conf 'telescope',
      requires = {
        {
          'nvim-telescope/telescope-fzf-native.nvim',
          run = 'make',
          after = 'telescope.nvim',
          config = function()
            require('telescope').load_extension 'fzf'
          end,
        },
        {
          'nvim-telescope/telescope-frecency.nvim',
          after = 'telescope.nvim',
          requires = 'tami5/sqlite.lua',
        },
        {
          'camgraff/telescope-tmux.nvim',
          after = 'telescope.nvim',
          config = function()
            require('telescope').load_extension 'tmux'
          end,
        },
        {
          'nvim-telescope/telescope-smart-history.nvim',
          after = 'telescope.nvim',
          config = function()
            require('telescope').load_extension 'smart_history'
          end,
        },
      },
    }

    use { 'folke/which-key.nvim', config = conf 'whichkey' }

    use 'nvim-lua/plenary.nvim'

    use 'kyazdani42/nvim-web-devicons'

    use {
      'vuki656/package-info.nvim',
      disable = true,
      requires = 'MunifTanjim/nui.nvim',
      config = function()
        require('package-info').setup()
      end,
    }

    use {
      'vim-test/vim-test',
      cmd = { 'Test*' },
      keys = { '<localleader>tf', '<localleader>tn', '<localleader>ts' },
      setup = function()
        require('which-key').register({
          t = {
            name = '+vim-test',
            f = 'test: file',
            n = 'test: nearest',
            s = 'test: suite',
          },
        }, {
          prefix = '<localleader>',
        })
      end,
      config = function()
        vim.g['test#strategy'] = 'kitty'
        fss.nnoremap('<localleader>tf', '<cmd>TestFile<CR>')
        fss.nnoremap('<localleader>tn', '<cmd>TestNearest<CR>')
        fss.nnoremap('<localleader>ts', '<cmd>TestSuite<CR>')
      end,
    }

    use {
      'rcarriga/vim-ultest',
      cmd = 'Ultest',
      wants = 'vim-test',
      event = { 'BufEnter *_test.*,*_spec.*' },
      requires = { 'vim-test' },
      run = ':UpdateRemotePlugins',
      config = function()
        local test_patterns = { '*.test.*', '*_test.*', '*_spec.*' }
        fss.augroup('UltestTests', {
          {
            events = { 'BufWritePost' },
            targets = test_patterns,
            command = 'UltestNearest',
          },
        })
        fss.nmap(']T', '<Plug>(ultest-next-fail)', {
          label = 'ultest: next failure',
          buffer = 0,
        })
        fss.nmap('[T', '<Plug>(ultest-prev-fail)', {
          label = 'ultest: previous failure',
          buffer = 0,
        })
      end,
    }

    use {
      'rmagatti/auto-session',
      disable = false,
      config = function()
        require('auto-session').setup {
          auto_session_root_dir = ('%s/session/auto/'):format(vim.fn.stdpath 'data'),
        }
      end,
    }

    use {
      'christoomey/vim-tmux-navigator',
      cond = function()
        return vim.env.TMUX ~= nil
      end,
      config = function()
        vim.g.tmux_navigator_no_mappings = 1
        fss.nnoremap('<C-H>', '<cmd>TmuxNavigateLeft<cr>')
        fss.nnoremap('<C-J>', '<cmd>TmuxNavigateDown<cr>')
        fss.nnoremap('<C-K>', '<cmd>TmuxNavigateUp<cr>')
        fss.nnoremap('<C-L>', '<cmd>TmuxNavigateRight<cr>')
        -- Disable tmux navigator when zooming the Vim pane
        vim.g.tmux_navigator_disable_when_zoomed = 1
        vim.g.tmux_navigator_preserve_zoom = 1
        vim.g.tmux_navigator_save_on_switch = 2
      end,
    }

    use {
      'knubie/vim-kitty-navigator',
      run = 'cp ./*.py ~/.config/kitty/',
      cond = function()
        return vim.env.TMUX == nil
      end,
    }

    use {
      'rmagatti/session-lens',
      disable = true,
      after = 'telescope.nvim',
      config = function()
        local session_lens = require 'session-lens'
        require('which-key').register {
          ['<leader>fS'] = {
            session_lens.search_session,
            'sessions',
          },
        }
      end,
    }

    use {
      'akinsho/toggleterm.nvim',
      local_path = 'personal',
      config = function()
        require('toggleterm').setup {
          open_mapping = [[<c-\>]],
          shade_filetypes = { 'none' },
          direction = 'vertical',
          start_in_insert = true,
          float_opts = { border = 'curved', winblend = 3 },
          size = function(term)
            if term.direction == 'horizontal' then
              return 15
            elseif term.direction == 'vertical' then
              return math.floor(vim.o.columns * 0.4)
            end
          end,
        }

        local float_handler = function(term)
          if vim.fn.mapcheck('jk', 't') ~= '' then
            vim.api.nvim_buf_del_keymap(term.bufnr, 't', 'jk')
            vim.api.nvim_buf_del_keymap(term.bufnr, 't', '<esc>')
          end
        end

        local Terminal = require('toggleterm.terminal').Terminal

        local lazygit = Terminal:new {
          cmd = 'lazygit',
          dir = 'git_dir',
          hidden = true,
          direction = 'float',
          on_open = float_handler,
        }

        local htop = Terminal:new {
          cmd = 'htop',
          hidden = 'true',
          direction = 'float',
          on_open = float_handler,
        }

        fss.command {
          'Htop',
          function()
            htop:toggle()
          end,
        }

        require('which-key').register {
          ['<leader>lg'] = {
            function()
              lazygit:toggle()
            end,
            'toggleterm: toggle lazygit',
          },
        }
      end,
    }

    use 'tpope/vim-eunuch'

    use 'tpope/vim-repeat'

    use {
      'tpope/vim-abolish',
      config = function()
        local opts = { silent = false }
        fss.nnoremap('<localleader>[', ':S/<C-R><C-W>//<LEFT>', opts)
        fss.nnoremap('<localleader>]', ':%S/<C-r><C-w>//c<left><left>', opts)
        fss.xnoremap('<localleader>[', [["zy:%S/<C-r><C-o>"//c<left><left>]], opts)
      end,
    }

    -- sets searchable path for filetypes like go so 'gf' works
    use 'tpope/vim-apathy'

    -- }}}
    -----------------------------------------------------------------------------//
    -- Language, Completion & Debugger {{{
    -----------------------------------------------------------------------------//

    use {
      'mfussenegger/nvim-dap',
      module = 'dap',
      keys = { '<localleader>dc' },
      wants = 'nvim-dap-ui',
      setup = conf('dap').setup,
      config = conf('dap').config,
      requires = {
        {
          'rcarriga/nvim-dap-ui',
          opt = true,
          config = function()
            require('dapui').setup()
          end,
        },
      },
    }

    use 'folke/lua-dev.nvim'

    use { 'neovim/nvim-lspconfig', config = conf 'lspconfig' }
    use {
      'williamboman/nvim-lsp-installer',
      requires = 'nvim-lspconfig',
      config = function()
        local lsp_installer_servers = require 'nvim-lsp-installer.servers'
        for name, _ in pairs(fss.lsp.servers) do
          ---@type boolean, table|string
          local ok, server = lsp_installer_servers.get_server(name)
          if ok then
            if not server:is_installed() then
              server:install()
            end
          end
        end
      end,
    }

    use {
      'j-hui/fidget.nvim',
      config = function()
        require('fidget').setup {}
      end,
    }

    use 'jose-elias-alvarez/nvim-lsp-ts-utils'

    use {
      'jose-elias-alvarez/null-ls.nvim',
      run = function()
        utils.install('write-good', 'npm', 'install -g')
      end,
      requires = { 'nvim-lua/plenary.nvim' },
      config = function()
        local null_ls = require 'null-ls'
        local builtins = null_ls.builtins
        null_ls.setup {
          debug = true,
          debounce = 150,
          on_attach = fss.lsp.on_attach,
          sources = {
            builtins.hover.dictionary,
            builtins.diagnostics.zsh,
            builtins.diagnostics.write_good,
            builtins.code_actions.gitsigns,
            builtins.formatting.mix,
            builtins.formatting.prettier,
            null_ls.builtins.formatting.stylua.with {
              condition = function(_utils)
                return fss.executable 'stylua'
                  and _utils.root_has_file { 'stylua.toml', '.stylua.toml' }
              end,
            },
          },
        }
      end,
    }

    use {
      'ray-x/lsp_signature.nvim',
      disable = false,
      config = function()
        require('lsp_signature').setup {
          bind = true,
          fix_pos = false,
          auto_close_after = 15, -- close after 15 seconds
          hint_enable = false,
          handler_opts = { border = 'rounded' },
        }
      end,
    }

    use {
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
        { 'petertriho/cmp-git', after = 'nvim-cmp' },
        { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
        {
          'petertriho/cmp-git',
          after = 'nvim-cmp',
          config = function()
            require('cmp_git').setup {
              filetypes = { 'gitcommit', 'NeogitCommitMessage' },
            }
          end,
        },
        {
          'tzachar/cmp-fuzzy-path',
          after = 'cmp-path',
          requires = { 'hrsh7th/cmp-path', 'tzachar/fuzzy.nvim' },
        },
        {
          'tzachar/cmp-fuzzy-buffer',
          after = 'nvim-cmp',
          requires = { 'tzachar/fuzzy.nvim' },
        },
      },
      config = conf 'cmp',
    }

    use {
      'AckslD/nvim-neoclip.lua',
      disable = true,
      config = function()
        require('neoclip').setup {
          enable_persistant_history = true,
          keys = {
            i = { select = '<c-p>', paste = '<CR>', paste_behind = '<c-k>' },
            n = { select = 'p', paste = '<CR>', paste_behind = 'P' },
          },
        }
        local function clip()
          require('telescope').extensions.neoclip.default(
            require('telescope.themes').get_dropdown()
          )
        end

        require('which-key').register {
          ['<localleader>p'] = { clip, 'neoclip: open yank history' },
        }
      end,
    }

    use {
      'L3MON4D3/LuaSnip',
      event = 'InsertEnter',
      module = 'luasnip',
      requires = 'rafamadriz/friendly-snippets',
      config = conf 'luasnip',
    }

    use {
      'folke/trouble.nvim',
      keys = { '<leader>ld' },
      cmd = { 'TroubleToggle' },
      setup = function()
        require('which-key').register {
          ['<leader>l'] = {
            d = 'trouble: toggle',
            r = 'trouble: lsp references',
          },
          ['[d'] = 'trouble: next item',
          [']d'] = 'trouble: previous item',
        }
      end,
      requires = 'nvim-web-devicons',
      config = function()
        local H = require 'fss.highlights'
        H.plugin(
          'trouble',
          { 'TroubleNormal', { link = 'PanelBackground' } },
          { 'TroubleText', { link = 'PanelBackground' } },
          { 'TroubleIndent', { link = 'PanelVertSplit' } },
          { 'TroubleFoldIcon', { guifg = 'yellow', gui = 'bold' } },
          { 'TroubleLocation', { guifg = H.get_hl('Comment', 'fg') } }
        )
        local trouble = require 'trouble'
        fss.nnoremap('<leader>ld', '<cmd>TroubleToggle workspace_diagnostics<CR>')
        fss.nnoremap('<leader>lr', '<cmd>TroubleToggle lsp_references<CR>')
        fss.nnoremap(']d', function()
          trouble.previous { skip_groups = true, jump = true }
        end)
        fss.nnoremap('[d', function()
          trouble.next { skip_groups = true, jump = true }
        end)
        trouble.setup { auto_close = true, auto_preview = false }
      end,
    }

    use {
      'narutoxy/dim.lua',
      requires = { 'nvim-treesitter/nvim-treesitter', 'neovim/nvim-lspconfig' },
      config = function()
        require('dim').setup {
          disable_lsp_decorations = true,
        }
      end,
    }

    -- }}}
    -----------------------------------------------------------------------------//
    -- Syntax & Treesitter {{{
    -----------------------------------------------------------------------------//
    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = conf 'treesitter',
      local_path = 'contributing',
      requires = {
        {
          'nvim-treesitter/playground',
          cmd = 'TSPlaygroundToggle',
          module = 'nvim-treesitter-playground',
        },
      },
    }
    use {
      'nvim-treesitter/nvim-treesitter-textobjects',
      requires = 'nvim-treesitter',
    }
    use 'RRethy/nvim-treesitter-textsubjects'
    use { 'p00f/nvim-ts-rainbow', disable = true, requires = 'nvim-treesitter' }

    -- Use <Tab> to escape from pairs such as ""|''|() etc.
    use {
      'abecodes/tabout.nvim',
      wants = { 'nvim-treesitter' },
      after = { 'nvim-cmp' },
      config = function()
        require('tabout').setup {
          completion = false,
          ignore_beginning = false,
        }
      end,
    }

    use {
      'mizlan/iswap.nvim',
      cmd = { 'ISwap', 'ISwapWith' },
      keys = '<localleader>sw',
      config = function()
        require('iswap').setup {}
        require('which-key').register {
          ['<localleader>sw'] = {
            '<Cmd>ISwapWith<CR>',
            'swap arguments,parameters etc.',
          },
        }
      end,
    }

    use {
      'mfussenegger/nvim-ts-hint-textobject',
      config = function()
        fss.omap('m', ":<C-U>lua require('tsht').nodes()<CR>")
        fss.xnoremap('m', ":'<'>lua require('tsht').nodes()<CR>")
      end,
    }

    use {
      'lewis6991/spellsitter.nvim',
      disable = true,
      config = function()
        require('spellsitter').setup {
          enable = true,
        }
      end,
    }

    use 'windwp/nvim-ts-autotag'
    use 'mtdl9/vim-log-highlighting'
    use 'slime-lang/vim-slime-syntax'
    use 'plasticboy/vim-markdown'
    use 'jparise/vim-graphql'

    use 'sainnhe/everforest'
    use 'folke/tokyonight.nvim'
    use 'NTBBloodbath/doom-one.nvim'

    -- }}}
    --------------------------------------------------------------------------------
    -- Git {{{
    --------------------------------------------------------------------------------

    use {
      'TimUntersberger/neogit',
      cmd = 'Neogit',
      keys = { '<localleader>gs', '<localleader>gl', '<localleader>gp' },
      requires = 'plenary.nvim',
      setup = conf('neogit').setup,
      config = conf('neogit').config,
    }

    use {
      'sindrets/diffview.nvim',
      cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
      module = 'diffview',
      keys = '<localleader>gd',
      setup = function()
        require('which-key').register { ['<localleader>gd'] = 'diffview: diff HEAD' }
      end,
      config = function()
        fss.nnoremap('<localleader>gd', '<Cmd>DiffviewOpen<CR>')
        require('diffview').setup {
          enhanced_diff_hl = true,
          key_bindings = {
            file_panel = { q = '<Cmd>DiffviewClose<CR>' },
            view = { q = '<Cmd>DiffviewClose<CR>' },
          },
        }
      end,
    }

    use {
      'lewis6991/gitsigns.nvim',
      config = conf 'gitsigns',
      requires = { 'nvim-lua/plenary.nvim' },
    }

    use {
      'rhysd/conflict-marker.vim',
      config = function()
        require('fss.highlights').plugin(
          'conflictMarker',
          { 'ConflictMarkerBegin', { guibg = '#2f7366' } },
          { 'ConflictMarkerOurs', { guibg = '#2e5049' } },
          { 'ConflictMarkerTheirs', { guibg = '#344f69' } },
          { 'ConflictMarkerEnd', { guibg = '#2f628e' } },
          { 'ConflictMarkerCommonAncestorsHunk', { guibg = '#754a81' } }
        )
        -- disable the default highlight group
        vim.g.conflict_marker_highlight_group = ''
        -- Include text after begin and end markers
        vim.g.conflict_marker_begin = '^<<<<<<< .*$'
        vim.g.conflict_marker_end = '^>>>>>>> .*$'
      end,
    }

    use {
      'pwntester/octo.nvim',
      cmd = 'Octo*',
      setup = function()
        require('which-key').register {
          ['<localleader>o'] = {
            name = '+octo',
            p = { name = '+pull-request', l = { '<cmd>Octo pr list<CR>', 'list' } },
            i = { name = '+issues', l = { '<cmd>Octo issue list<CR>', 'list' } },
          },
        }
      end,
      config = function()
        require('octo').setup()
      end,
    }

    use {
      'rlch/github-notifications.nvim',
      -- don't load this plugin if the gh cli is not installed
      cond = function()
        return fss.executable 'gh'
      end,
      requires = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    }

    ---}}}
    --------------------------------------------------------------------------------
    -- Utilites {{{
    --------------------------------------------------------------------------------

    use {
      'stevearc/dressing.nvim',
      config = function()
        require('dressing').setup {
          select = {
            input = {
              insert_only = false,
            },
            telescope = {
              theme = 'cursor',
            },
          },
        }
      end,
    }

    use {
      'moll/vim-bbye',
      setup = function()
        require('which-key').register {
          ['<leader>qq'] = { '<cmd>Bdelete!<cr>', 'delete buffer' },
        }
      end,
    }

    use {
      'lukas-reineke/indent-blankline.nvim',
      config = function()
        require('indent_blankline').setup {
          char = '│', -- ┆ ┊ 
          show_foldtext = false,
          show_first_indent_level = true,
          show_current_context = true,
          show_current_context_start = true,
          filetype_exclude = {
            'startify',
            'dashboard',
            'log',
            'fugitive',
            'gitcommit',
            'packer',
            'vimwiki',
            'markdown',
            'json',
            'txt',
            'vista',
            'help',
            'NvimTree',
            'NeoTree',
            'git',
            'TelescopePrompt',
            'undotree',
            'flutterToolsOutline',
            'norg',
            'org',
            'orgagenda',
            '', -- for all buffers without a file type
          },
          buftype_exclude = { 'terminal', 'nofile' },
          context_patterns = {
            'class',
            'function',
            'method',
            'block',
            'list_literal',
            'selector',
            '^if',
            '^table',
            'if_statement',
            'while',
            'for',
          },
        }
      end,
    }

    -- A better bufferline
    use {
      'akinsho/bufferline.nvim',
      config = conf 'bufferline',
      requires = 'kyazdani42/nvim-web-devicons',
    }

    -- Multiple cursors
    use {
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
    }

    use {
      'kyazdani42/nvim-tree.lua',
      disable = false,
      config = conf 'nvimtree',
      requires = 'nvim-web-devicons',
    }

    use 'MunifTanjim/nui.nvim'

    use {
      'petertriho/nvim-scrollbar',
      config = function()
        local colors = require('tokyonight.colors').setup()

        require('scrollbar').setup {
          handle = {
            color = '#32384F',
          },
          -- NOTE: If telescope is not explicitly excluded this garbles input into its prompt buffer
          excluded_filetypes = { 'packer', 'TelescopePrompt' },
          excluded_buftypes = { 'terminal', 'prompt' },
          marks = {
            Search = { color = colors.orange },
            Error = { color = colors.error },
            Warn = { color = colors.warning },
            Info = { color = colors.info },
            Hint = { color = colors.hint },
            Misc = { color = colors.purple },
          },
        }
      end,
    }

    use {
      'anuvyklack/pretty-fold.nvim',
      disable = true,
      config = function()
        require('pretty-fold').setup {
          fill_char = ' ',
        }
        require('pretty-fold.preview').setup_keybinding()
      end,
    }

    -- use 'tpope/vim-vinegar'
    -- use 'justinmk/vim-dirvish'

    use {
      'folke/zen-mode.nvim',
      disable = false,
      cmd = { 'ZenMode' },
      config = function()
        require('zen-mode').setup {
          window = {
            backdrop = 1,
            options = {
              number = false,
              relativenumber = false,
            },
          },
          {
            gitsigns = true,
          },
        }
        require('which-key').register {
          ['<leader>ze'] = { '<cmd>ZenMode<CR>', 'Zen' },
        }
      end,
    }

    use 'folke/twilight.nvim'

    use {
      'iamcco/markdown-preview.nvim',
      run = function()
        vim.fn['mkdp#util#install']()
      end,
      ft = { 'markdown' },
      config = function()
        vim.g.mkdp_auto_start = 0
        vim.g.mkdp_auto_close = 1
      end,
    }

    use {
      'rrethy/vim-hexokinase',
      disable = true,
      run = 'make hexokinase',
      config = function()
        vim.g.copilot_no_tab_map = true
        vim.g.Hexokinase_executable_path = '~/go/bin/hexokinase'
      end,
    }

    -- prevent select and visual mode from overwriting the clipboard
    use {
      'kevinhwang91/nvim-hclipboard',
      config = function()
        require('hclipboard').start()
      end,
    }

    use {
      'github/copilot.vim',
      config = function()
        vim.g.copilot_filetypes = {
          ['*'] = false,
          gitcommit = false,
          NeogitCommitMessage = false,
          lua = true,
          javascript = true,
          typescript = true,
          typescriptreact = true,
          javascriptreact = true,
        }
        fss.imap('<c-h>', [[copilot#Accept("\<CR>")]], { expr = true, script = true })
        vim.g.copilot_no_tab_map = true
        vim.g.copilot_assume_mapped = true
        vim.g.copilot_tab_fallback = ''
        require('fss.highlights').plugin('copilot', {
          'CopilotSuggestion',
          { link = 'Comment', force = true },
        })
      end,
    }

    -----------------------------------------------------------------------------//
    -- Quickfix
    -----------------------------------------------------------------------------//
    use {
      'yorickpeterse/nvim-pqf',
      event = 'BufReadPre',
      config = function()
        require('fss.highlights').plugin(
          'NvimPQF',
          { 'qfPosition', { link = 'Tag', force = true } }
        )
        require('pqf').setup {}
      end,
    }

    use {
      'kevinhwang91/nvim-bqf',
      config = function()
        local H = require 'fss.highlights'
        local comment_fg = H.get_hl('Comment', 'fg')
        H.plugin('bqf', { 'BqfPreviewBorder', { guifg = comment_fg } })
      end,
    }

    ---}}}
    --------------------------------------------------------------------------------
    -- Search Tools {{{
    --------------------------------------------------------------------------------

    use 'ggandor/lightspeed.nvim'

    ---}}}
    --------------------------------------------------------------------------------
    -- Editing {{{
    --------------------------------------------------------------------------------

    use { 'junegunn/vim-easy-align', cmd = 'EasyAlign' }

    use {
      'mbbill/undotree',
      cmd = 'UndotreeToggle',
      keys = '<leader>u',
      config = function()
        vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
        vim.g.undotree_SetFocusWhenToggle = 1
        require('which-key').register {
          ['<leader>u'] = 'undotree: toggle',
        }
      end,
    }

    use {
      'rcarriga/nvim-notify',
      config = function()
        local notify = require 'notify'
        notify.setup {
          timeout = 3000,
        }
        ---Send a notification
        --@param msg of the notification to show to the user
        --@param level Optional log level
        --@param opts Dictionary with optional options (timeout, etc)
        vim.notify = function(msg, level, opts)
          local l = vim.log.levels
          assert(type(level) ~= 'table', 'level should be one of vim.log.levels or a string')
          opts = opts or {}
          level = level or l.INFO
          local levels = {
            [l.DEBUG] = 'Debug',
            [l.INFO] = 'Information',
            [l.WARN] = 'Warning',
            [l.ERROR] = 'Error',
          }
          opts.title = opts.title or type(level) == 'string' and level or levels[level]
          notify(msg, level, opts)
        end
        local hls = { DEBUG = 'Normal', INFO = 'Directory', WARN = 'WarningMsg', ERROR = 'Error' }
        fss.command {
          'NotificationHistory',
          function()
            local history = notify.history()
            local messages = vim.tbl_map(function(notif)
              return { unpack(notif.message), hls[notif.level] }
            end, history)
            for _, message in ipairs(messages) do
              vim.api.nvim_echo({ message }, true, {})
            end
          end,
        }
      end,
    }

    use {
      'windwp/nvim-autopairs',
      after = 'nvim-cmp',
      config = function()
        require('nvim-autopairs').setup {
          close_triple_quotes = true,
          check_ts = false,
        }
      end,
    }

    use {
      'tpope/vim-surround',
      config = function()
        fss.xmap('s', '<Plug>VSurround')
        fss.xmap('s', '<Plug>VSurround')
      end,
    }

    use 'AndrewRadev/splitjoin.vim'

    use {
      'Matt-A-Bennett/vim-surround-funk',
      config = function()
        vim.g.surround_funk_create_mappings = 0
        require('which-key').register {
          d = {
            name = '+dsf: function text object',
            s = {
              f = { '<Plug>(DeleteSurroundingFunction)', 'delete surrounding function' },
              F = { '<Plug>(DeleteSurroundingFUNCTION)', 'delete surrounding outer function' },
            },
          },
          c = {
            name = '+dsf: function text object',
            s = {
              f = { '<Plug>(ChangeSurroundingFunction)', 'change surrounding function' },
              F = { '<Plug>(ChangeSurroundingFUNCTION)', 'change outer surrounding function' },
            },
          },
        }
      end,
    }

    -- Easy accessible digraphs
    use {
      'protex/better-digraphs.nvim',
      config = function()
        fss.inoremap('<C-k><C-k>', function()
          require('betterdigraphs').digraphs 'i'
        end)
        fss.nnoremap('r<C-k><C-k>', function()
          require('betterdigraphs').digraphs 'r'
        end)
        fss.vnoremap('r<C-k><C-k>', function()
          require('betterdigraphs').digraphs 'gvr'
        end)
      end,
    }

    -- Commenting made better
    use {
      'numToStr/Comment.nvim',
      config = function()
        require('Comment').setup()
      end,
    }

    -- Provides Line wise and delimiter sorting via :Sort
    use 'sQVe/sort.nvim'

    -- More useful word motions for  vim
    -- https://github.com/chaoren/vim-wordmotion
    use 'chaoren/vim-wordmotion'

    -- Cycle open and closed folds
    use 'arecarn/vim-fold-cycle'

    -- See the cursor jump
    use {
      'danilamihailov/beacon.nvim',
      config = function()
        require('fss.highlights').plugin('beacon', { 'Beacon', { ctermbg = 50 } })
      end,
    }

    use {
      'chentau/marks.nvim',
      config = function()
        require('fss.highlights').plugin('marks', { 'MarkSignHL', { guifg = 'Red' } })
        require('marks').setup {
          -- builtin_marks = { '.', '^' },
          bookmark_0 = {
            sign = '⚑',
            virt_text = 'bookmarks',
          },
        }
      end,
    }

    -- Highlight ranges you enter in the command line
    use {
      'winston0410/range-highlight.nvim',
      disable = true,
      config = function()
        require('range-highlight').setup()
      end,
    }

    ---}}}
    --------------------------------------------------------------------------------
    -- Knowledge and task management {{{
    --------------------------------------------------------------------------------

    use {
      'vhyrro/neorg',
      requires = { 'vhyrro/neorg-telescope' },
      config = function()
        fss.nnoremap('<localleader>oc', '<Cmd>Neorg gtd capture<CR>')
        fss.nnoremap('<localleader>ov', '<Cmd>Neorg gtd views<CR>')
        require('neorg').setup {
          load = {
            ['core.defaults'] = {},
            -- TODO: cannot unmap <c-s> and segfaults, raise an issue
            ['core.integrations.telescope'] = {},
            ['core.keybinds'] = {
              config = {
                default_keybinds = true,
                neorg_leader = '<localleader>',
                hook = function(keybinds)
                  keybinds.map_event(
                    'norg',
                    'n',
                    '<C-x>',
                    'core.integrations.telescope.find_linkable'
                  )
                end,
              },
            },
            ['core.norg.completion'] = {
              config = {
                engine = 'nvim-cmp',
              },
            },
            ['core.norg.concealer'] = {},
            ['core.norg.dirman'] = {
              config = {
                workspaces = {
                  notes = '~/Desktop/Personal/main/',
                  tasks = '~/Desktop/Personal/tasks/',
                },
              },
            },
            ['core.gtd.base'] = {
              config = {
                workspace = 'tasks',
              },
            },
          },
        }
      end,
    }

    -- This plugin adds horizontal highlights for text filetypes
    use {
      'lukas-reineke/headlines.nvim',
      disable = true,
      config = function()
        require('headlines').setup()
      end,
    }

    -- Replaces the asterisks in org syntax with unicode characters
    use {
      'akinsho/org-bullets.nvim',
      disable = false,
      config = function()
        require('org-bullets').setup()
      end,
    }

    ---}}}
    --------------------------------------------------------------------------------
    -- Profiling & Startup {{{
    --------------------------------------------------------------------------------

    -- NOTE: this plugin will be redundant once https://github.com/neovim/neovim/pull/15436 is merged
    use 'lewis6991/impatient.nvim'

    use {
      'dstein64/vim-startuptime',
      cmd = 'StartupTime',
      config = function()
        vim.g.startuptime_tries = 15
        vim.g.startuptime_exe_args = { '+let g:auto_session_enabled = 0' }
      end,
    }
    ---}}}
    --------------------------------------------------------------------------------
  end,
  log = { level = 'info' },
  config = {
    compile_path = PACKER_COMPILED_PATH,
    display = {
      prompt_border = 'rounded',
      open_cmd = 'silent topleft 65vnew',
    },
    profile = {
      enable = true,
      threshold = 1,
    },
  },
}

fss.command {
  'PackerCompiledEdit',
  function()
    vim.cmd(fmt('edit %s', PACKER_COMPILED_PATH))
  end,
}

fss.command {
  'PackerCompiledDelete',
  function()
    vim.fn.delete(PACKER_COMPILED_PATH)
    packer_notify(fmt('Deleted %s', PACKER_COMPILED_PATH))
  end,
}

if not vim.g.packer_compiled_loaded then
  fss.source(PACKER_COMPILED_PATH)
  vim.g.packer_compiled_loaded = true
end

fss.augroup('PackerSetupInit', {
  {
    events = { 'BufWritePost' },
    targets = { '*/fss/plugins/*.lua' },
    command = function()
      fss.invalidate('fss.plugins', true)
      require('packer').compile()
    end,
  },
  {
    events = { 'User PackerCompileDone' },
    command = function()
      vim.notify('Packer compile complete', nil, { title = 'Packer' })
    end,
  },
})

fss.nnoremap('<leader>ps', [[<Cmd>PackerSync<CR>]])
fss.nnoremap('<leader>pc', [[<Cmd>PackerClean<CR>]])

-- vim:foldmethod=marker
