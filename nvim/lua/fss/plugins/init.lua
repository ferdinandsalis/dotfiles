local utils = require 'fss.plugins.utils'

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

-- FIXME: currently because mpack is required BEFORE packer
-- loads it can't be loaded by packer which doesn't set the
-- packpath till later in the setup process e.g. when packer compiled is loaded
-- so the following command needs to be manually executed
-- luarocks install --lua-version=5.1 mpack
local ok, impatient = fss.safe_require 'impatient'
if ok then
  impatient.enable_profile()
end

-- NOTE: luarocks install on every single PackerInstall https://github.com/wbthomason/packer.nvim/issues/180

require('packer').startup {
  function(use, use_rocks)
    use { 'wbthomason/packer.nvim', opt = true }

    -----------------------------------------------------------------------------//
    -- Core {{{
    -----------------------------------------------------------------------------//

    use_rocks 'penlight'

    -- NOTE: this plugin will be redundant once https://github.com/neovim/neovim/pull/15436 is merged
    use 'lewis6991/impatient.nvim'

    use {
      'ahmedkhalf/project.nvim',
      config = function()
        require('project_nvim').setup()
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
          { 'SnapSelect', { link = 'TelescopeSelection', force = true } },
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
      'nvim-telescope/telescope.nvim',
      event = 'CursorHold',
      config = conf 'telescope',
      requires = {
        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
        { 'nvim-telescope/telescope-frecency.nvim', requires = 'tami5/sqlite.lua' },
        { 'nvim-telescope/telescope-smart-history.nvim' },
      },
    }

    use { 'folke/which-key.nvim', config = conf 'whichkey' }

    use 'nvim-lua/plenary.nvim'

    use 'kyazdani42/nvim-web-devicons'

    use {
      'vim-test/vim-test',
      cmd = { 'Test*' },
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
          auto_session_root_dir = ('%s/session/auto/'):format(vim.fn.stdpath 'data'),
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
      'akinsho/toggleterm.nvim',
      config = function()
        require('toggleterm').setup {
          open_mapping = [[<c-\>]],
          shade_filetypes = { 'none' },
          direction = 'vertical',
          start_in_insert = true,
          shading_factor = 0.5,
          float_opts = { border = 'curved' },
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
    use { 'tpope/vim-apathy', ft = { 'go', 'python', 'javascript', 'typescript' } }

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

    use {
      'kabouzeid/nvim-lspinstall',
      module = 'lspinstall',
      requires = 'nvim-lspconfig',
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
    }

    use {
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
    }

    use {
      'kosayoda/nvim-lightbulb',
      config = function()
        fss.augroup('NvimLightbulb', {
          {
            events = { 'CursorHold', 'CursorHoldI' },
            targets = { '*' },
            command = function()
              require('nvim-lightbulb').update_lightbulb {
                sign = { enabled = false },
                virtual_text = { enabled = true },
              }
            end,
          },
        })
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
      end,
    }

    -- use {
    --   'ray-x/lsp_signature.nvim',
    --   config = function()
    --     require('lsp_signature').setup {
    --       bind = true,
    --       fix_pos = function(signatures, _) -- second argument is the client
    --         return signatures[1].activeParameter >= 0 and signatures[1].parameters > 1
    --       end,
    --       hint_enable = false,
    --       handler_opts = {
    --         border = 'rounded',
    --       },
    --     }
    --   end,
    -- }

    use {
      'hrsh7th/nvim-cmp',
      module = 'cmp',
      event = 'InsertEnter',
      requires = {
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'f3fora/cmp-spell', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
        { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
        { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
      },
      config = conf 'cmp',
    }

    use {
      'AckslD/nvim-neoclip.lua',
      config = function()
        require('neoclip').setup {
          keys = {
            i = {
              select = '<c-p>',
              paste = '<CR>',
              paste_behind = '<c-k>',
            },
            n = {
              select = 'p',
              paste = '<CR>',
              paste_behind = 'P',
            },
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
        fss.nnoremap('<leader>ld', '<cmd>TroubleToggle lsp_workspace_diagnostics<CR>')
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

    -- Use <Tab> to escape from pairs such as ""|''|() etc.
    use {
      'abecodes/tabout.nvim',
      wants = { 'nvim-treesitter' },
      after = { 'nvim-cmp' },
      config = function()
        require('tabout').setup {
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

    use 'NTBBloodbath/doom-one.nvim'

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
      cmd = { 'DiffviewOpen', 'DiffViewFileHistory' },
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
    -- Utilites {{{
    --------------------------------------------------------------------------------

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
      config = conf 'indentline',
    }

    use {
      'akinsho/bufferline.nvim',
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

    -- use 'justinmk/vim-dirvish'

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

    -- prevent select and visual mode from overwriting the clipboard
    use {
      'kevinhwang91/nvim-hclipboard',
      config = function()
        require('hclipboard').start()
      end,
    }

    ---}}}
    --------------------------------------------------------------------------------
    -- Search Tools {{{
    --------------------------------------------------------------------------------

    -- lazy load as it is very expensive to load during startup i.e. 20ms+
    -- FIXME: UpdateRemotePlugins doesn't seem to be called for lazy loaded plugins
    --@see: https://github.com/wbthomason/packer.nvim/issues/464
    use {
      'gelguy/wilder.nvim',
      -- event = { 'CursorHold', 'CmdlineEnter' },
      rocks = { 'luarocks-fetch-gitrec', 'pcre2' },
      requires = { 'romgrk/fzy-lua-native' },
      config = function()
        fss.source 'vimscript/wilder.vim'
      end,
    }

    use 'ggandor/lightspeed.nvim'

    ---}}}
    --------------------------------------------------------------------------------
    -- Editing {{{
    --------------------------------------------------------------------------------

    use { 'tversteeg/registers.nvim', opt = true }
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
    use 'chaoren/vim-wordmotion'
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
    use {
      'dstein64/vim-startuptime',
      cmd = 'StartupTime',
      config = function()
        vim.g.startuptime_tries = 10
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

fss.augroup('PackerSetupInit', {
  {
    events = { 'BufWritePost' },
    targets = { '*/fss/plugins/*.lua' },
    command = function()
      fss.invalidate('fss.plugins', true)
      require('packer').compile()
      packer_notify 'packer compiled...'
    end,
  },
})

fss.nnoremap('<leader>ps', [[<Cmd>PackerSync<CR>]])
fss.nnoremap('<leader>pc', [[<Cmd>PackerClean<CR>]])

if not vim.g.packer_compiled_loaded then
  vim.cmd(fmt('source %s', PACKER_COMPILED_PATH))
  vim.g.packer_compiled_loaded = true
end

-- vim:foldmethod=marker
