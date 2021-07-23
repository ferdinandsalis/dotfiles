return function()
  local telescope = require("telescope")
  local actions = require("telescope.actions")
  local themes = require("telescope.themes")

  local H = require("fss.highlights")
  local normal_bg = H.get_hl("Normal", "bg")
  local comment_fg = H.get_hl("Comment", "fg")
  require("fss.highlights").plugin(
    "telescope",
    {"TelescopePathSeparator", {link = "Directory"}},
    {"TelescopeQueryFilter", {link = "IncSearch"}},
    {"TelescopeResultsBorder", {guibg = normal_bg, guifg = comment_fg}},
    {"TelescopePromptBorder", {guibg = normal_bg, guifg = comment_fg}},
    {"TelescopePreviewBorder", {guibg = normal_bg, guifg = comment_fg}},
    {"TelescopePreviewNormal", {guibg = normal_bg, guifg = normal_bg}}
  )

  telescope.setup {
    defaults = {
      set_env = {["TERM"] = vim.env.TERM},
      prompt_prefix = " ",
      mappings = {
        i = {
          ["<c-c>"] = function()
            vim.cmd "stopinsert!"
          end,
          ["<esc>"] = actions.close,
          ["<c-s>"] = actions.select_horizontal,
          ["<c-j>"] = actions.cycle_history_next,
          ["<c-k>"] = actions.cycle_history_prev
        }
      },
      file_ignore_patterns = {"%.jpg", "%.jpeg", "%.png", "%.otf", "%.ttf"},
      layout_strategy = "flex",
      winblend = 7
    },
    extensions = {
      frecency = {
        -- the filter is saved so passing a :CWD: tag would not work
        -- without turning this option off
        -- @see: https://github.com/nvim-telescope/telescope-frecency.nvim/issues/16
        persistent_filter = false,
        workspaces = {
          ["conf"] = vim.env.DOTFILES,
          ["project"] = vim.env.PROJECTS_DIR
        }
      },
      fzf = {
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true -- override the file sorter
      }
    },
    pickers = {
      buffers = {
        sort_lastused = true,
        show_all_buffers = true,
        mappings = {
          i = {["<c-x>"] = "delete_buffer"},
          n = {["<c-x>"] = "delete_buffer"}
        }
      },
      lsp_code_actions = {
        theme = "cursor"
      },
      colorscheme = {
        enable_preview = true
      },
      find_files = {
        hidden = true
      },
      git_branches = {
        theme = "dropdown"
      },
      reloader = {
        theme = "dropdown"
      }
    }
  }

  telescope.load_extension "fzf"
  telescope.load_extension "smart_history"

  --- NOTE: this must be required after setting up telescope
  --- otherwise the result will be cached without the updates
  --- from the setup call
  local builtins = require("telescope.builtin")

  local function frecency()
    telescope.extensions.frecency.frecency(
      themes.get_dropdown {
        default_text = ":CWD:",
        winblend = 10,
        border = true,
        previewer = false,
        shorten_path = false
      }
    )
  end

  require("which-key").register(
    {
      ["<leader>f"] = {
        name = "+find",
        a = {builtins.builtin, "builtins"},
        g = {
          name = "+git",
          c = {builtins.git_commits, "commits"},
          b = {builtins.git_branches, "branches"}
        },
        m = {builtins.man_pages, "man pages"},
        h = {frecency, "history"},
        r = {builtins.reloader, "module reloader"},
        ["?"] = {builtins.help_tags, "help"}
      },
      ["<leader>c"] = {
        d = {builtins.lsp_workspace_diagnostics, "telescope: workspace diagnostics"}
      }
    }
  )
end
