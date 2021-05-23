--- Global treesitter object containing treesitter related utilities
fss.ts = {}

---Get all filetypes for which we have a treesitter parser installed
---@return string[]
function fss.ts.get_filetypes()
  local parsers = require("nvim-treesitter.parsers")
  local configs = parsers.get_parser_configs()
  return vim.tbl_map(
    function(ft)
      return configs[ft].filetype or ft
    end,
    parsers.available_parsers()
  )
end

return function()
  vim.cmd [[highlight link TSKeyword Statement]]
  vim.cmd [[highlight TSParameter gui=italic,bold]]

  require("nvim-treesitter.configs").setup {
    ensure_installed = "maintained",
    highlight = {
      enable = true,
      ignore_install = {"verilog"}
    },
    context_commentstring = {
      enable = true
    },
    autotag = {
      enable = true
    },
    rainbow = {
      enable = true,
      disable = {"lua", "json"},
      extended_mode = true
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        -- mappings for incremental selection (visual mappings)
        init_selection = "<leader>v", -- maps in normal mode to init the node/scope selection
        node_incremental = "<leader>v", -- increment to the upper named parent
        node_decremental = "<leader>V", -- decrement to the previous node
        scope_incremental = "grc" -- increment to the upper scope (as defined in locals.scm)
      }
    },
    indent = {
      enable = true
    },
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["aC"] = "@conditional.outer",
          ["iC"] = "@conditional.inner"
        }
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer"
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer"
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer"
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer"
        }
      }
    },
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = {"BufWrite", "CursorHold"}
    }
  }

  -- Only apply folding to supported files:
  fss.augroup(
    "TreesitterFolds",
    {
      {
        events = {"FileType"},
        targets = fss.ts.get_filetypes(),
        command = "setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()"
      }
    }
  )
end
