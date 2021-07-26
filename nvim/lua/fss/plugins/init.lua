local fn = vim.fn
local fmt = string.format

local PACKER_COMPILED_PATH = fn.stdpath 'cache' .. '/packer/packer_compiled.lua'

-----------------------------------------------------------------------------//
-- Bootstrap Packer {{{
-----------------------------------------------------------------------------//
-- Make sure packer is installed on the current machine and load
-- the dev or upstream version depending on if we are at work or not
-- NOTE: install packer as an opt plugin since it's loaded conditionally on my local machine
-- it needs to be installed as optional so the install dir is consistent across machines
local install_path = fmt('%s/site/pack/packer/opt/packer.nvim', fn.stdpath 'data')
if fn.empty(fn.glob(install_path)) > 0 then
  vim.notify 'Downloading packer.nvim...'
  vim.notify(
    fn.system { 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path }
  )
  vim.cmd 'packadd! packer.nvim'
  require('packer').sync()
else
  local name = vim.env.DEVELOPING and 'local-packer.nvim' or 'packer.nvim'
  vim.cmd(fmt('packadd! %s', name))
end
-- }}}

-- cfilter plugin allows filter down an existing quickfix list
vim.cmd 'packadd! cfilter'

fss.augroup('PackerSetupInit', {
  {
    events = { 'BufWritePost' },
    targets = { '*/fss/plugins/*.lua' },
    command = function()
      fss.invalidate('fss.plugins', true)
      require('packer').compile()
      vim.notify 'packer compiled...'
    end,
  },
})
fss.nnoremap('<leader>ps', [[<Cmd>PackerSync<CR>]])
fss.nnoremap('<leader>pc', [[<Cmd>PackerClean<CR>]])

---Require a plugin config
---@param name string
---@return function
local function conf(name)
  return require(string.format('fss.plugins.%s', name))
end

-- NOTE: luarocks install on every single PackerInstall https://github.com/wbthomason/packer.nvim/issues/180

require('packer').startup {
  function(use, use_rocks)
    use { 'wbthomason/packer.nvim', opt = true }
    -----------------------------------------------------------------------------//
    -- Core {{{
    -----------------------------------------------------------------------------//
    use_rocks 'penlight'

    use {
      'airblade/vim-rooter',
      config = function()
        vim.g.rooter_silent_chdir = 0
        vim.g.rooter_patterns = {
          '.git',
          'samconfig.toml',
          'package.json',
        }
      end,
    }
    use {
      'camspiers/snap',
      rocks = { 'fzy' },
      event = 'CursorHold',
      keys = { '<C-p>' },
      setup = function()
        require('which-key').register({
          ['f'] = {
            o = 'snap: buffers',
            p = 'snap: project files',
            s = 'snap: grep',
            c = 'snap: cursor word',
            d = 'snap: dotfiles',
            O = 'snap: org files',
          },
        }, {
          prefix = '<leader>',
        })
      end,
      config = function()
        local H = require 'fss.highlights'
        local comment_fg = H.get_hl('Comment', 'fg')
        require('fss.highlights').plugin(
          'snap',
          { 'SnapSelect', { link = 'TextInfoBold', force = true } },
          { 'SnapPosition', { link = 'Keyword', force = true } },
          { 'SnapBorder', { guifg = comment_fg } }
        )

        local snap = require 'snap'
        local config = require 'snap.config'
        local file = config.file:with {
          reverse = true,
          suffix = ' »',
          consumer = 'fzy',
        }
        local vimgrep = config.vimgrep:with {
          suffix = ' »',
          reverse = true,
          limit = 50000,
        }
        local args = { '--hidden', '--iglob', '!{.git/*,zsh/plugins/*,dotbot/*}' }
        snap.maps {
          {
            '<c-p>',
            file { prompt = 'Project', args = args, try = { 'git.file', 'ripgrep.file' } },
            { command = 'project-files' },
          },
          {
            '<leader>fp',
            file { prompt = 'Project', args = args, try = { 'git.file', 'ripgrep.file' } },
            { command = 'project-files' },
          },
          {
            '<leader>fd',
            file {
              prompt = 'Dotfiles',
              producer = 'ripgrep.file',
              args = { vim.env.DOTFILES, unpack(args) },
            },
            { command = 'dots' },
          },
          {
            '<leader>fO',
            file {
              prompt = 'Org',
              producer = 'ripgrep.file',
              args = { vim.fn.expand '~/Desktop/Orgmode/' },
            },
            { command = 'org' },
          },
          { '<leader>fs', vimgrep { limit = 50000, args = args }, { command = 'grep' } },
          { '<leader>fc', vimgrep { prompt = 'Find word', args = args, filter_with = 'cword' } },
          { '<leader>fo', file { producer = 'vim.buffer' }, { command = 'buffers' } },
        }
      end,
    }

    use {
      'jose-elias-alvarez/null-ls.nvim',
      requires = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
      -- trigger loading after lspconfig has started the other servers
      -- since there is otherwise a race condition and null-ls' setup would
      -- have to be moved into lspconfig.lua otherwise
      event = 'User LspServersStarted',
      config = function()
        local null_ls = require 'null-ls'
        null_ls.config {
          debounce = 150,
          sources = {
            null_ls.builtins.code_actions.gitsigns,
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.formatting.prettierd,
          },
        }
        require('lspconfig')['null-ls'].setup {
          on_attach = fss.lsp.on_attach,
        }
        print 'lsp-null setup'
      end,
    }

    use {
      'nvim-telescope/telescope.nvim',
      event = 'CursorHold',
      keys = { '<c-p>' },
      config = conf 'telescope',
      requires = {
        'nvim-lua/popup.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
        {
          'nvim-telescope/telescope-frecency.nvim',
          requires = 'tami5/sql.nvim',
          after = 'telescope.nvim',
        },
        { 'nvim-telescope/telescope-smart-history.nvim' },
      },
    }
    use { 'folke/which-key.nvim', config = conf 'whichkey' }
    use 'nvim-lua/plenary.nvim'
    use 'kyazdani42/nvim-web-devicons'
    use {
      'vim-test/vim-test',
      cmd = { 'TestFile', 'TestNearest', 'TestSuite' },
      keys = { '<localleader>tf', '<localleader>tn', '<localleader>ts' },
      config = function()
        vim.cmd [[
            let test#strategy = "neovim"
            let test#neovim#term_position = "vert botright"
            let g:test#javascript#jest#executable = 'yarn test'
            let g:test#javascript#runner = 'jest'
          ]]
        require('which-key').register {
          ['<localleader>t'] = {
            name = '+vim-test',
            f = {
              '<cmd>TestFile<CR>',
              'test: file',
            },
            n = {
              '<cmd>TestNearest<CR>',
              'test: nearest',
            },
            s = {
              '<cmd>TestSuite<CR>',
              'test: suite',
            },
          },
        }
      end,
    }
    use {
      'rcarriga/vim-ultest',
      opt = true,
      cmd = { 'Ultest', 'UltestNearest' },
      requires = { 'vim-test/vim-test' },
      run = ':UpdateRemotePlugins',
    }
    use {
      'rmagatti/auto-session',
      config = function()
        require('auto-session').setup {
          auto_session_root_dir = vim.fn.stdpath 'data' .. '/session/auto/',
        }
      end,
    }
    use {
      'rmagatti/session-lens',
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
      'akinsho/nvim-toggleterm.lua',
      keys = [[<c-\>]],
      config = function()
        local large_screen = vim.o.columns > 200
        require('toggleterm').setup {
          size = function(term)
            if term.direction == 'horizontal' then
              return 15
            elseif term.direction == 'vertical' then
              return vim.o.columns * 0.4
            end
          end,
          open_mapping = [[<c-\>]],
          shade_filetypes = { 'none' },
          shading_factor = 0.5,
          direction = large_screen and 'vertical' or 'horizontal',
          float_opts = {
            border = 'rounded',
          },
        }
      end,
    }
    -- use {"tpope/vim-projectionist", config = conf("projectionist")}
    -- use "tpope/vim-sleuth"
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
    use { 'tpope/vim-apathy', ft = { 'go', 'python', 'javascript', 'typescript' } }
    -- }}}
    -----------------------------------------------------------------------------//
    -- Language, Completion & Debugger {{{
    -----------------------------------------------------------------------------//
    -- use {
    --   "mhartington/formatter.nvim",
    --   config = function()
    --     local function prettierd()
    --       return {
    --         exe = "prettierd",
    --         args = {vim.api.nvim_buf_get_name(0)},
    --         stdin = true
    --       }
    --     end
    --     vim.api.nvim_exec(
    --       [[
    --         augroup FormatAutogroup
    --         autocmd!
    --         autocmd BufWritePost *.js,*.jsx,*.rs,*.lua FormatWrite
    --         augroup END
    --       ]],
    --       true
    --     )
    --     require("formatter").setup(
    --       {
    --         logging = false,
    --         silent = true,
    --         filetype = {
    --           -- typescript = {prettierd},
    --           -- typescriptreact = {prettierd},
    --           -- javascript = {prettierd},
    --           -- javascriptreact = {prettierd},
    --           rust = {
    --             -- Rustfmt
    --             function()
    --               return {
    --                 exe = "rustfmt",
    --                 args = {"--emit=stdout"},
    --                 stdin = true
    --               }
    --             end
    --           },
    --           -- lua = {
    --           --   -- luafmt
    --           --   function()
    --           --     return {
    --           --       exe = "luafmt",
    --           --       args = {"--indent-count", 2, "--stdin"},
    --           --       stdin = true
    --           --     }
    --           --   end
    --           -- }
    --         }
    --       }
    --     )
    --   end
    -- }
    use {
      'mfussenegger/nvim-dap',
      config = conf 'dap',
      module = 'dap',
      keys = { '<localleader>dtc' },
    }
    use {
      'rcarriga/nvim-dap-ui',
      requires = 'nvim-dap',
      after = 'nvim-dap',
      config = function()
        require('dapui').setup()
      end,
    }
    use 'folke/lua-dev.nvim'
    use {
      'kabouzeid/nvim-lspinstall',
      module = 'lspinstall',
      config = function()
        require('lspinstall').post_install_hook = function()
          fss.lsp.setup_servers()
          vim.cmd 'bufdo e'
        end
      end,
    }
    use {
      'neovim/nvim-lspconfig',
      event = 'BufReadPre',
      config = conf 'lspconfig',
      requires = {
        {
          'nvim-lua/lsp-status.nvim',
          config = function()
            local status = require 'lsp-status'
            status.config {
              indicator_hint = '',
              indicator_info = '',
              indicator_errors = '✗',
              indicator_warnings = '',
              status_symbol = ' ',
            }
            status.register_progress()
          end,
        },
        -- {
        --   "glepnir/lspsaga.nvim",
        --   config = conf("lspsaga")
        -- }
      },
    }
    use {
      'ray-x/lsp_signature.nvim',
      config = function()
        require('lsp_signature').setup {
          bind = true,
          fix_pos = false,
          hint_enable = false,
          handler_opts = {
            border = 'rounded',
          },
        }
      end,
    }
    use {
      'hrsh7th/nvim-compe',
      config = conf 'compe',
      event = 'InsertEnter',
    }
    use {
      'hrsh7th/vim-vsnip',
      event = 'InsertEnter',
      requires = { 'rafamadriz/friendly-snippets', 'hrsh7th/nvim-compe' },
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
        fss.nnoremap('<leader>ld', '<cmd>TroubleToggle lsp_workspace_diagnostics<CR>')
        fss.nnoremap('<leader>lr', '<cmd>TroubleToggle lsp_references<CR>')
        require('trouble').setup { auto_close = true, auto_preview = false }
      end,
    }
    use {
      'folke/todo-comments.nvim',
      requires = 'nvim-lua/plenary.nvim',
      config = function()
        require('todo-comments').setup {
          highlight = {
            exclude = { 'org', 'orgagenda', 'markdown' },
          },
        }
      end,
    }
    -- }}}
    -----------------------------------------------------------------------------//
    -- Syntax {{{
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
    use {
      'p00f/nvim-ts-rainbow',
      requires = 'nvim-treesitter',
      config = function()
        require('fss.highlights').plugin(
          'rainbow',
          { 'rainbowcol1', { guifg = '#a3be8c' } },
          { 'rainbowcol2', { guifg = '#99c2c1' } },
          { 'rainbowcol3', { guifg = '#8fbcbb' } },
          { 'rainbowcol4', { guifg = '#88c0d0' } },
          { 'rainbowcol5', { guifg = '#81a1c1' } },
          { 'rainbowcol6', { guifg = '#5e81ac' } },
          { 'rainbowcol7', { guifg = '#4e6f97' } }
        )
      end,
    }

    use {
      'abecodes/tabout.nvim',
      config = function()
        require('tabout').setup {
          tabkey = '<Tab>', -- key to trigger tabout
          act_as_tab = true, -- shift content if tab out is not possible
          completion = true, -- if the tabkey is used in a completion pum
          tabouts = {
            { open = "'", close = "'" },
            { open = '"', close = '"' },
            { open = '`', close = '`' },
            { open = '(', close = ')' },
            { open = '[', close = ']' },
            { open = '{', close = '}' },
          },
          ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
          exclude = {}, -- tabout will ignore these filetypes
        }
      end,
      wants = { 'nvim-treesitter' }, -- or require if not used so far
      after = { 'nvim-compe' }, -- if a completion plugin is using tabs load it before
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
      'lewis6991/spellsitter.nvim',
      opt = true,
      config = function()
        require('spellsitter').setup {
          hl = 'SpellBad',
          captures = { 'comment' },
        }
      end,
    }
    use 'windwp/nvim-ts-autotag'
    use 'mtdl9/vim-log-highlighting'
    use 'plasticboy/vim-markdown'
    use 'folke/tokyonight.nvim'
    use {
      'projekt0n/github-nvim-theme',
      event = 'ColorScheme github',
      config = function()
        require('github-theme').setup()
      end,
    }
    -- }}}
    --------------------------------------------------------------------------------
    -- Git {{{
    --------------------------------------------------------------------------------
    use { 'TimUntersberger/neogit', config = conf 'neogit' }
    use {
      'sindrets/diffview.nvim',
      cmd = 'DiffviewOpen',
      module = 'diffview',
      keys = '<localleader>gd',
      config = function()
        local cb = require('diffview.config').diffview_callback
        require('which-key').register(
          { gd = { '<Cmd>DiffviewOpen<CR>', 'diff ref' } },
          { prefix = '<localleader>' }
        )
        require('diffview').setup {
          key_bindings = {
            file_panel = {
              ['q'] = '<Cmd>DiffviewClose<CR>',
              ['j'] = cb 'next_entry', -- Bring the cursor to the next file entry
              ['<down>'] = cb 'next_entry',
              ['k'] = cb 'prev_entry', -- Bring the cursor to the previous file entry.
              ['<up>'] = cb 'prev_entry',
              ['<cr>'] = cb 'select_entry', -- Open the diff for the selected entry.
              ['o'] = cb 'select_entry',
              ['R'] = cb 'refresh_files', -- Update stats and entries in the file list.
              ['<tab>'] = cb 'select_next_entry',
              ['<s-tab>'] = cb 'select_prev_entry',
              ['<leader>e'] = cb 'focus_files',
              ['<leader>b'] = cb 'toggle_files',
            },
            view = {
              ['q'] = '<Cmd>DiffviewClose<CR>',
              ['<tab>'] = cb 'select_next_entry', -- Open the diff for the next file
              ['<s-tab>'] = cb 'select_prev_entry', -- Open the diff for the previous file
              ['<leader>e'] = cb 'focus_files', -- Bring focus to the files panel
              ['<leader>b'] = cb 'toggle_files', -- Toggle the files panel.
            },
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
          'ConflictMarker',
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
      cmd = 'Octo',
      keys = { '<localleader>opl' },
      config = function()
        require('octo').setup()
        require('which-key').register({
          o = {
            name = '+octo',
            p = {
              l = {
                '<cmd>Octo pr list<CR>',
                'PR List',
              },
            },
          },
        }, {
          prefix = '<localleader>',
        })
      end,
    }
    ---}}}
    --------------------------------------------------------------------------------
    -- Chrome {{{
    --------------------------------------------------------------------------------
    use {
      'lukas-reineke/indent-blankline.nvim',
      config = conf 'indentline',
    }
    use {
      'akinsho/nvim-bufferline.lua',
      config = conf 'bufferline',
      requires = 'kyazdani42/nvim-web-devicons',
    }
    use {
      'karb94/neoscroll.nvim',
      config = function()
        require('neoscroll').setup {
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
        }
      end,
    }
    use 'justinmk/vim-dirvish'
    use {
      'kyazdani42/nvim-tree.lua',
      config = conf 'tree',
      requires = 'nvim-web-devicons',
    }
    use {
      'folke/zen-mode.nvim',
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
      'norcalli/nvim-colorizer.lua',
      config = function()
        require('colorizer').setup()
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
    -- Editing {{{
    --------------------------------------------------------------------------------
    use 'ggandor/lightspeed.nvim'
    use 'tversteeg/registers.nvim'
    use 'kshenoy/vim-signature'
    use { 'junegunn/vim-easy-align', cmd = 'EasyAlign' }
    use {
      'mbbill/undotree',
      cmd = 'UndotreeToggle',
      keys = '<leader>u',
      setup = function()
        require('which-key').register {
          ['<leader>u'] = 'undotree: toggle',
        }
      end,
      config = function()
        vim.g.undotree_TreeNodeShape = '◉' -- Alternative: '◦'
        vim.g.undotree_SetFocusWhenToggle = 1
      end,
    }
    use {
      'windwp/nvim-autopairs',
      config = function()
        require('nvim-autopairs').setup {
          close_triple_quotes = true,
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
      'AndrewRadev/dsf.vim',
      setup = function()
        require('which-key').register {
          d = {
            name = '+dsf: function text object',
            s = {
              f = {
                '<Plug>DsfDelete',
                'delete surrounding function',
              },
              nf = {
                '<Plug>DsfNextDelete',
                'delete next surrounding function',
              },
            },
          },
          c = {
            name = '+dsf: function text object',
            s = {
              f = {
                '<Plug>DsfChange',
                'change surrounding function',
              },
              nf = {
                '<Plug>DsfNextChange',
                'change next surrounding function',
              },
            },
          },
        }
      end,
      config = function()
        vim.g.dsf_no_mappings = 1
      end,
    }
    use { 'b3nj5m1n/kommentary', config = conf 'kommentary' }
    use 'arecarn/vim-fold-cycle'
    use {
      'winston0410/range-highlight.nvim',
      opt = true,
      config = function()
        require('range-highlight').setup()
      end,
    }
    ---}}}
    --------------------------------------------------------------------------------
    -- Knowledge and task management {{{
    --------------------------------------------------------------------------------
    use {
      'kristijanhusak/orgmode.nvim',
      config = conf 'orgmode',
    }
    use {
      'soywod/himalaya', --- Email in nvim
      rtp = 'vim',
      run = 'curl -sSL https://raw.githubusercontent.com/soywod/himalaya/master/install.sh | PREFIX=~/.local sh',
      config = function()
        require('which-key').register({
          e = {
            name = '+email',
            l = { '<Cmd>Himalaya<CR>', 'list' },
          },
        }, {
          prefix = '<localleader>',
        })
      end,
    }
    ---}}}
    --------------------------------------------------------------------------------
    -- Profiling {{{
    --------------------------------------------------------------------------------
    use { 'tweekmonster/startuptime.vim', cmd = 'StartupTime' }
    ---}}}
    --------------------------------------------------------------------------------
  end,
  log = { level = 'error' },
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
    vim.notify(fmt('Deleted %s', PACKER_COMPILED_PATH))
  end,
}

if not vim.g.packer_compiled_loaded then
  vim.cmd(fmt('source %s', PACKER_COMPILED_PATH))
  vim.g.packer_compiled_loaded = true
end

-- vim:foldmethod=marker
