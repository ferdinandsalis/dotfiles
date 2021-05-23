local fn = vim.fn
local has = fss.has
local fmt = string.format

local PACKER_COMPILED_PATH = fn.stdpath("cache") .. "/packer/packer_compiled.vim"

local function setup_packer()
  local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    print("Downloading packer.nvim...")
    print(fn.system({"git", "clone", "https://github.com/wbthomason/packer.nvim", install_path}))
    vim.cmd("packadd packer.nvim")
    require("packer").sync()
  else
    vim.cmd("packadd packer.nvim")
  end
end

setup_packer()

fss.augroup(
  "PackerSetupInit",
  {
    {
      events = {"BufWritePost"},
      targets = {"*/fss/plugins/*.lua"},
      command = function()
        fss.invalidate("fss.plugins", true)
        require("packer").compile()
        vim.notify("packer compiled ...")
      end
    }
  }
)
fss.nnoremap("<leader>ps", [[<Cmd>PackerSync<CR>]])
fss.nnoremap("<leader>pc", [[<Cmd>PackerClean<CR>]])

local openssl_dir = has("mac") and "/opt/homebrew/Cellar/openssl@1.1/1.1.1k" or "/usr/"

local function conf(name)
  return require(string.format("fss.plugins.%s", name))
end

require("packer").startup(
  {
    function(use, use_rocks)
      use {"wbthomason/packer.nvim", opt = true}

      -- General:
      use_rocks "penlight"

      use {"folke/which-key.nvim", config = conf("whichkey")}
      use "nvim-lua/popup.nvim"
      use "nvim-lua/plenary.nvim"
      use "mhinz/vim-grepper"
      use "kyazdani42/nvim-web-devicons"
      use {"mhinz/vim-sayonara", cmd = "Sayonara"}

      -- use {
      --   "airblade/vim-rooter",
      --   config = function()
      --     vim.g.rooter_silent_chdir = 0
      --     vim.g.rooter_patterns = {".git", "samconfig.toml", "package.json"}
      --   end
      -- }

      use {"ahmedkhalf/lsp-rooter.nvim"}

      use {
        "vim-test/vim-test",
        cmd = {"TestFile", "TestNearest", "TestSuite"},
        keys = {"<localleader>tf", "<localleader>tn", "<localleader>ts"},
        config = function()
          vim.cmd [[
            let test#strategy = "neovim"
            let test#neovim#term_position = "vert botright"
            let g:test#runnder_commands = ['Jest']
            let g:test#javascript#jest#executable = 'npx jest'
            let g:test#javascript#runner = 'jest'
            let g:test#javascript#jest#file_pattern = '.test\.js'
          ]]
          require("which-key").register(
            {
              ["<localleader>t"] = {
                name = "+vim-test",
                f = {"<cmd>TestFile<CR>", "test: file"},
                n = {"<cmd>TestNearest<CR>", "test: nearest"},
                s = {"<cmd>TestSuite<CR>", "test: suite"}
              }
            }
          )
        end
      }

      -- use {
      --   "rmagatti/auto-session",
      --   config = function()
      --     require("auto-session").setup {
      --       auto_session_root_dir = vim.fn.stdpath("data") .. "/session/auto/"
      --     }
      --   end
      -- }

      use {
        "akinsho/nvim-toggleterm.lua",
        keys = [[<c-\>]],
        config = function()
          local large_screen = vim.o.columns > 200
          require("toggleterm").setup {
            size = function(term)
              if term.direction == "horizontal" then
                return 15
              elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
              end
            end,
            persist_size = false,
            open_mapping = [[<c-\>]],
            shade_filetypes = {"none"},
            shading_factor = 0.5,
            direction = large_screen and "vertical" or "horizontal",
            float_opts = {
              border = "single"
            }
          }
        end
      }

      use {"tpope/vim-projectionist", config = conf("projectionist")}
      use "tpope/vim-eunuch"
      use "tpope/vim-repeat"
      use {
        "tpope/vim-abolish",
        config = function()
          local opts = {silent = false}
          fss.nnoremap("<localleader>[", ":S/<C-R><C-W>//<LEFT>", opts)
          fss.nnoremap("<localleader>]", ":%S/<C-r><C-w>//c<left><left>", opts)
          fss.vnoremap("<localleader>[", [["zy:%S/<C-r><C-o>"//c<left><left>]], opts)
        end
      }
      -- sets searchable path for filetypes like go so 'gf' works
      use {"tpope/vim-apathy", ft = {"go", "python", "javascript", "typescript"}}

      -- Autocomplete & Snippets:
      use {
        "hrsh7th/nvim-compe",
        config = conf("compe"),
        event = "InsertEnter"
      }

      use {
        "tzachar/compe-tabnine",
        run = "./install.sh",
        after = "nvim-compe",
        requires = "hrsh7th/nvim-compe"
      }

      use {
        "hrsh7th/vim-vsnip",
        -- config = conf("vim-vsnip"),
        event = "InsertEnter",
        requires = {"rafamadriz/friendly-snippets", "hrsh7th/nvim-compe"}
      }

      use {
        "nvim-telescope/telescope.nvim",
        event = "CursorHold",
        config = conf("telescope"),
        requires = {
          "nvim-lua/popup.nvim",
          "nvim-telescope/telescope-fzf-writer.nvim",
          {"nvim-telescope/telescope-fzf-native.nvim", run = "make"},
          {
            "nvim-telescope/telescope-frecency.nvim",
            requires = "tami5/sql.nvim",
            after = "telescope.nvim"
          },
          {
            "nvim-telescope/telescope-arecibo.nvim",
            rocks = {{"openssl", env = {OPENSSL_DIR = openssl_dir}}, "lua-http-parser"}
          }
        }
      }

      -- use {"rmagatti/session-lens", after = "telescope.nvim"}

      -- Language & Syntax:

      use {
        "neovim/nvim-lspconfig",
        config = conf("lspconfig"),
        requires = {
          {
            "nvim-lua/lsp-status.nvim",
            config = function()
              local status = require("lsp-status")
              status.config {
                indicator_hint = "",
                indicator_info = "",
                indicator_errors = "✗",
                indicator_warnings = "",
                status_symbol = " "
              }
              status.register_progress()
            end
          },
          {
            "glepnir/lspsaga.nvim",
            opt = true,
            config = conf("lspsaga")
          },
          {
            "kabouzeid/nvim-lspinstall",
            opt = true,
            config = function()
              require("lspinstall").post_install_hook = function()
                fss.lsp.setup_servers()
                fss.cmd("bufdo e")
              end
            end
          }
        }
      }

      use "ray-x/lsp_signature.nvim"

      use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = conf("treesitter"),
        local_path = "contributing",
        requires = {
          {
            "nvim-treesitter/playground",
            cmd = "TSPlaygroundToggle",
            module = "nvim-treesitter-playground"
          }
        }
      }

      use {
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
        requires = "nvim-treesitter"
      }

      use {
        "lewis6991/spellsitter.nvim",
        opt = true,
        config = function()
          require("spellsitter").setup {hl = "SpellBad", captures = {"comment"}}
        end
      }

      use "romgrk/nvim-treesitter-context"
      use "windwp/nvim-ts-autotag"
      use "JoosepAlviste/nvim-ts-context-commentstring"
      use "p00f/nvim-ts-rainbow"

      use {
        "folke/trouble.nvim",
        keys = {"<leader>ld"},
        cmd = {"TroubleToggle"},
        requires = "nvim-web-devicons",
        config = function()
          require("which-key").register(
            {
              ["<leader>ld"] = {
                "<cmd>TroubleToggle lsp_workspace_diagnostics<CR>",
                "lsp trouble: toggle"
              },
              ["<leader>lr"] = {"<cmd>TroubleToggle lsp_references<cr>", "lsp trouble: references"}
            }
          )
          require("fss.highlights").all {
            {"TroubleNormal", {link = "PanelBackground"}},
            {"TroubleText", {link = "PanelBackground"}},
            {"TroubleIndent", {link = "PanelVertSplit"}},
            {"TroubleFoldIcon", {guifg = "yellow", gui = "bold"}}
          }
          require("trouble").setup {auto_close = true, auto_preview = false}
        end
      }

      use {
        "folke/todo-comments.nvim",
        requires = "nvim-lua/plenary.nvim",
        config = function()
          require("todo-comments").setup {}
        end
      }

      use "folke/tokyonight.nvim"
      use "mtdl9/vim-log-highlighting"

      -- TODO: this breaks when used with sessions but keep an eye on it
      use {
        "sunjon/Shade.nvim",
        opt = true,
        config = function()
          require("shade").setup()
        end
      }

      --------------------------------------------------------------------------------
      -- Git {{{
      --------------------------------------------------------------------------------

      use {"TimUntersberger/neogit", config = conf("neogit")}

      use {
        "ruifm/gitlinker.nvim",
        requires = "plenary.nvim",
        setup = function()
          require("which-key").register({["<localleader>gu"] = "gitlinker: get line url"})
        end,
        config = function()
          require("gitlinker").setup {opts = {mappings = "<localleader>gu"}}
        end
      }

      use {
        "sindrets/diffview.nvim",
        cmd = "DiffviewOpen",
        module = "diffview",
        keys = "<localleader>gd",
        config = function()
          local cb = require("diffview.config").diffview_callback
          require("which-key").register(
            {["<localleader>gd"] = {"<Cmd>DiffviewOpen<CR>", "diffview: diff ref"}}
          )
          require("diffview").setup(
            {
              key_bindings = {
                file_panel = {
                  ["q"] = "<Cmd>DiffviewClose<CR>",
                  ["j"] = cb("next_entry"), -- Bring the cursor to the next file entry
                  ["<down>"] = cb("next_entry"),
                  ["k"] = cb("prev_entry"), -- Bring the cursor to the previous file entry.
                  ["<up>"] = cb("prev_entry"),
                  ["<cr>"] = cb("select_entry"), -- Open the diff for the selected entry.
                  ["o"] = cb("select_entry"),
                  ["R"] = cb("refresh_files"), -- Update stats and entries in the file list.
                  ["<tab>"] = cb("select_next_entry"),
                  ["<s-tab>"] = cb("select_prev_entry"),
                  ["<leader>e"] = cb("focus_files"),
                  ["<leader>b"] = cb("toggle_files")
                },
                view = {q = "<Cmd>DiffviewClose<CR>"}
              }
            }
          )
        end
      }

      use {
        "lewis6991/gitsigns.nvim",
        config = conf("gitsigns"),
        requires = {"nvim-lua/plenary.nvim"}
      }

      use {
        "rhysd/conflict-marker.vim",
        config = function()
          -- disable the default highlight group
          vim.g.conflict_marker_highlight_group = ""
          -- Include text after begin and end markers
          vim.g.conflict_marker_begin = "^<<<<<<< .*$"
          vim.g.conflict_marker_end = "^>>>>>>> .*$"
        end
      }

      use {
        "pwntester/octo.nvim",
        cmd = "Octo",
        keys = {"<localleader>opl"},
        config = function()
          require("octo").setup()
          require("which-key").register(
            {
              o = {
                name = "+octo",
                p = {
                  l = {"<cmd>Octo pr list<CR>", "PR List"}
                }
              }
            },
            {prefix = "<localleader>"}
          )
        end
      }

      ---}}}

      --------------------------------------------------------------------------------
      -- Chrome {{{
      --------------------------------------------------------------------------------

      use {
        "lukas-reineke/indent-blankline.nvim",
        config = conf("indentline"),
        branch = "lua"
      }

      use {
        "akinsho/nvim-bufferline.lua",
        config = conf("bufferline"),
        requires = "kyazdani42/nvim-web-devicons"
      }

      use {
        "karb94/neoscroll.nvim",
        config = function()
          require("neoscroll").setup {
            mappings = {"<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "zt", "zz", "zb"}
          }
        end
      }

      use {
        "kyazdani42/nvim-tree.lua",
        config = conf("tree"),
        requires = "nvim-web-devicons"
      }

      use {
        "folke/zen-mode.nvim",
        cmd = {"ZenMode"},
        config = function()
          require("zen-mode").setup {
            window = {
              backdrop = 1,
              options = {
                number = false,
                relativenumber = false
              }
            },
            {
              gitsigns = true
            }
          }
          require("which-key").register(
            {
              ["<leader>ze"] = {"<cmd>ZenMode<CR>", "Zen"}
            }
          )
        end
      }

      -- use("justinmk/vim-dirvish")

      use {"itchyny/vim-highlighturl", config = [[vim.g.highlighturl_guifg = "NONE"]]}

      use {
        "norcalli/nvim-colorizer.lua",
        config = function()
          require("colorizer").setup()
        end
      }

      use "kevinhwang91/nvim-bqf" -- Better quick fix
      use "junegunn/goyo.vim"
      use "junegunn/limelight.vim"

      --------------------------------------------------------------------------------
      -- Editing {{{
      --------------------------------------------------------------------------------

      use {
        "phaazon/hop.nvim",
        keys = {{"n", "s"}},
        config = function()
          local hop = require("hop")
          -- remove h,j,k,l from hops list of keys
          hop.setup {keys = "etovxqpdygfbzcisuran"}
          fss.nnoremap("s", hop.hint_char1)
        end
      }

      use "junegunn/vim-easy-align"
      use "tversteeg/registers.nvim"

      use {
        "mbbill/undotree",
        cmd = "UndotreeToggle",
        keys = "<leader>u",
        config = function()
          vim.g.undotree_TreeNodeShape = "◦" -- Alternative: '◉'
          vim.g.undotree_SetFocusWhenToggle = 1
          require("which-key").register(
            {["<leader>u"] = {"<cmd>UndotreeToggle<CR>", "toggle undotree"}}
          )
        end
      }

      use {
        "windwp/nvim-autopairs",
        config = function()
          require("nvim-autopairs").setup {
            close_triple_quotes = true
          }
        end
      }

      -- use {
      --   "AndrewRadev/tagalong.vim",
      --   ft = {"typescriptreact", "javascriptreact", "html"}
      -- }

      use {
        "tpope/vim-surround",
        config = function()
          fss.vmap("s", "<Plug>VSurround")
          fss.vmap("s", "<Plug>VSurround")
        end
      }

      use "AndrewRadev/splitjoin.vim"

      use {
        "AndrewRadev/sideways.vim",
        config = function()
          vim.g.sideways_add_item_cursor_restore = 1
          require("which-key").register(
            {
              ["]w"] = {"<cmd>SidewaysLeft<cr>", "move argument left"},
              ["[w"] = {"<cmd>SidewaysRight<cr>", "move argument right"},
              ["<localleader>s"] = {
                name = "+sideways",
                i = {"<Plug>SidewaysArgumentInsertBefore", "insert argument before"},
                a = {"<Plug>SidewaysArgumentAppendAfter", "insert argument after"},
                I = {"<Plug>SidewaysArgumentInsertFirst", "insert argument first"},
                A = {"<Plug>SidewaysArgumentAppendLast", "insert argument last"}
              }
            }
          )
        end
      }

      use {"b3nj5m1n/kommentary", config = conf("kommentary")}
      use "arecarn/vim-fold-cycle"
      use "machakann/vim-highlightedyank"
      use "romainl/vim-cool"

      use {
        "winston0410/range-highlight.nvim",
        opt = true,
        config = function()
          require("range-highlight").setup()
        end
      }

      ---}}}

      use {"soywod/himalaya", rtp = "vim"}

      --------------------------------------------------------------------------------
      -- Profiling {{{
      --------------------------------------------------------------------------------

      use {"tweekmonster/startuptime.vim", cmd = "StartupTime"}

      ---}}}
    end,
    config = {
      compile_path = PACKER_COMPILED_PATH,
      display = {
        open_cmd = "silent topleft 65vnew Packer"
      },
      profile = {
        enable = true,
        threshold = 1
      }
    }
  }
)

if not vim.g.packer_compiled_loaded then
  vim.cmd(fmt("source %s", PACKER_COMPILED_PATH))
  vim.g.packer_compiled_loaded = true
end
