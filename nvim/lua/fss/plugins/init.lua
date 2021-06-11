local fn = vim.fn
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

---Require a plugin config
---@param name string
---@return function
local function conf(name)
  return require(string.format("fss.plugins.%s", name))
end

require("packer").startup(
  {
    function(use, use_rocks)
      use {"wbthomason/packer.nvim", opt = true}

      -- -- General:
      use_rocks "penlight"

      -- use "ahmedkhalf/lsp-rooter.nvim"
      use {
        "airblade/vim-rooter",
        config = function()
          vim.g.rooter_silent_chdir = 0
          vim.g.rooter_patterns = {".git", "samconfig.toml", "package.json"}
        end
      }

      use {
        "rmagatti/goto-preview",
        config = function()
          require("goto-preview").setup {
            default_mappings = true
          }
        end
      }

      use {
        "camspiers/snap",
        rocks = {"fzy"},
        config = function()
          local snap = require("snap")
          local limit = snap.get("consumer.limit")
          local vimgrep = snap.get("select.vimgrep")
          snap.register.map(
            {"n"},
            {"<leader>fs"},
            function()
              snap.run {
                prompt = "Grep",
                producer = limit(10000, snap.get "producer.ripgrep.vimgrep"),
                select = vimgrep.select,
                multiselect = vimgrep.multiselect,
                views = {snap.get("preview.vimgrep")}
              }
            end
          )
        end
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
          }
        }
      }

      use {"folke/which-key.nvim", config = conf("whichkey")}
      use "nvim-lua/popup.nvim"
      use "nvim-lua/plenary.nvim"
      use "mhinz/vim-grepper"
      use "kyazdani42/nvim-web-devicons"

      use {
        "vim-test/vim-test",
        config = function()
          vim.cmd [[
            let test#strategy = "neovim"
            let test#neovim#term_position = "vert botright"
            let g:test#javascript#jest#executable = 'yarn test'
            let g:test#javascript#runner = 'jest'
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
      --   "rcarriga/vim-ultest",
      --   opt = true,
      --   cmd = {"Ultest", "UltestNearest"},
      --   requires = {"vim-test/vim-test"},
      --   run = ":UpdateRemotePlugins"
      -- }

      use {
        "rmagatti/auto-session",
        config = function()
          require("auto-session").setup {
            auto_session_root_dir = vim.fn.stdpath("data") .. "/session/auto/"
          }
        end
      }

      use {"rmagatti/session-lens", after = "telescope.nvim"}

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
      -- use {"tpope/vim-projectionist", config = conf("projectionist")}
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
      -- use {
      --   "tzachar/compe-tabnine",
      --   run = "./install.sh",
      --   after = "nvim-compe",
      --   requires = "hrsh7th/nvim-compe"
      -- }
      -- use {
      --   "hrsh7th/vim-vsnip",
      --   event = "InsertEnter",
      --   requires = {"rafamadriz/friendly-snippets", "hrsh7th/nvim-compe"}
      -- }
      -- Language & Syntax:
      --
      use "folke/lua-dev.nvim"

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
            "kosayoda/nvim-lightbulb",
            config = function()
              fss.augroup(
                "NvimLightbulb",
                {
                  {
                    events = {"CursorHold", "CursorHoldI"},
                    targets = {"*"},
                    command = function()
                      require("nvim-lightbulb").update_lightbulb {
                        sign = {enabled = false},
                        virtual_text = {enabled = true}
                      }
                    end
                  }
                }
              )
            end
          },
          {
            "glepnir/lspsaga.nvim",
            config = conf("lspsaga")
          },
          {
            "kabouzeid/nvim-lspinstall",
            config = function()
              require("lspinstall").post_install_hook = function()
                fss.lsp.setup_servers()
                fss.cmd("bufdo e")
              end
            end
          }
        }
      }
      use {"ray-x/lsp_signature.nvim"}
      -- Syntax
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
        requires = "nvim-treesitter"
      }
      use "RRethy/nvim-treesitter-textsubjects"
      use {
        "p00f/nvim-ts-rainbow",
        requires = "nvim-treesitter"
      }
      use {
        "mizlan/iswap.nvim",
        cmd = "ISwap",
        keys = "<localleader>sw",
        config = function()
          require("iswap").setup {}
          require("which-key").register(
            {
              ["<localleader>sw"] = {"<Cmd>ISwap<CR>", "swap arguments,parameters etc."}
            }
          )
        end
      }
      use {
        "lewis6991/spellsitter.nvim",
        opt = true,
        config = function()
          require("spellsitter").setup {hl = "SpellBad", captures = {"comment"}}
        end
      }
      use "windwp/nvim-ts-autotag"
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

      -- NOTE: this breaks when used with sessions but keep an eye on it
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
      -- use {
      --   "ruifm/gitlinker.nvim",
      --   requires = "plenary.nvim",
      --   setup = function()
      --     require("which-key").register({["<localleader>gu"] = "gitlinker: get line url"})
      --   end,
      --   config = function()
      --     require("gitlinker").setup {opts = {mappings = "<localleader>gu"}}
      --   end
      -- }
      use {
        "sindrets/diffview.nvim",
        cmd = "DiffviewOpen",
        module = "diffview",
        keys = "<localleader>gd",
        config = function()
          local cb = require("diffview.config").diffview_callback
          require("which-key").register(
            {gd = {"<Cmd>DiffviewOpen<CR>", "diff ref"}},
            {prefix = "<localleader>"}
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
                view = {
                  ["q"] = "<Cmd>DiffviewClose<CR>",
                  ["<tab>"] = cb("select_next_entry"), -- Open the diff for the next file
                  ["<s-tab>"] = cb("select_prev_entry"), -- Open the diff for the previous file
                  ["<leader>e"] = cb("focus_files"), -- Bring focus to the files panel
                  ["<leader>b"] = cb("toggle_files") -- Toggle the files panel.
                }
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
      use {
        "norcalli/nvim-colorizer.lua",
        config = function()
          require("colorizer").setup()
        end
      }
      use "kevinhwang91/nvim-bqf" -- Better quick fix

      --------------------------------------------------------------------------------
      -- Editing {{{
      --------------------------------------------------------------------------------

      use {
        "phaazon/hop.nvim",
        keys = {{"n", "s"}},
        config = function()
          local hop = require("hop")
          hop.setup {keys = "etovxqpdygfbzcisuran"} -- remove h,j,k,l from hops list of keys
          fss.nnoremap("s", hop.hint_char1)
        end
      }
      use {"junegunn/vim-easy-align", cmd = "EasyAlign"}
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
      use {
        "tpope/vim-surround",
        config = function()
          fss.vmap("s", "<Plug>VSurround")
          fss.vmap("s", "<Plug>VSurround")
        end
      }
      use "AndrewRadev/splitjoin.vim"
      use {
        "AndrewRadev/dsf.vim",
        config = function()
          vim.g.dsf_no_mappings = 1
          require("which-key").register(
            {
              d = {
                name = "+dsf: function text object",
                s = {
                  f = {"<Plug>DsfDelete", "delete surrounding function"},
                  nf = {"<Plug>DsfNextDelete", "delete next surrounding function"}
                }
              },
              c = {
                name = "+dsf: function text object",
                s = {
                  f = {"<Plug>DsfChange", "change surrounding function"},
                  nf = {"<Plug>DsfNextChange", "change next surrounding function"}
                }
              }
            }
          )
        end
      }
      use {"b3nj5m1n/kommentary", config = conf("kommentary")}
      use "arecarn/vim-fold-cycle"
      use {
        "winston0410/range-highlight.nvim",
        opt = true,
        config = function()
          require("range-highlight").setup()
        end
      }

      ---}}}
      use {
        "vhyrro/neorg",
        opt = true,
        requires = {"nvim-lua/plenary.nvim"},
        config = function()
          require("neorg").setup {
            load = {
              ["core.defaults"] = {}, -- Load all the default modules
              ["core.norg.concealer"] = {} -- Enhances the text editing experience by using icons
            }
          }
        end
      }
      use {
        "soywod/himalaya", --- Email in nvim
        rtp = "vim",
        run = "curl -sSL https://raw.githubusercontent.com/soywod/himalaya/master/install.sh | PREFIX=~/.local sh",
        config = function()
          require("which-key").register(
            {
              e = {
                name = "+email",
                l = {"<Cmd>Himalaya<CR>", "list"}
              }
            },
            {prefix = "<localleader>"}
          )
        end
      }

      --------------------------------------------------------------------------------
      -- Profiling {{{
      --------------------------------------------------------------------------------

      use {"tweekmonster/startuptime.vim", cmd = "StartupTime"}

      ---}}}
    end,
    config = {
      compile_path = PACKER_COMPILED_PATH,
      display = {
        prompt_border = fss.style.border.curved,
        open_cmd = "silent topleft 65vnew Packer"
      },
      profile = {
        enable = true,
        threshold = 1
      }
    }
  }
)

fss.command {
  "PackerCompiledEdit",
  function()
    vim.cmd(fmt("edit %s", PACKER_COMPILED_PATH))
  end
}

fss.command {
  "PackerCompiledDelete",
  function()
    vim.fn.delete(PACKER_COMPILED_PATH)
    vim.notify(fmt("Deleted %s"))
  end
}

if not vim.g.packer_compiled_loaded then
  vim.cmd(fmt("source %s", PACKER_COMPILED_PATH))
  vim.g.packer_compiled_loaded = true
end
