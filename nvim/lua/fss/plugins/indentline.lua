return function()
  vim.g.indent_blankline_char = "│" -- 
  vim.g.indent_blankline_show_foldtext = false
  vim.g.indent_blankline_show_first_indent_level = true
  vim.g.indent_blankline_filetype_exclude = {
    "log",
    "fugitive",
    "gitcommit",
    "packer",
    "markdown",
    "json",
    "txt",
    "help",
    "todoist",
    "NvimTree",
    "git",
    "TelescopePrompt",
    "undotree",
    "" -- for all buffers without a file type
  }
  vim.g.indent_blankline_buftype_exclude = {"terminal", "nofile"}
  vim.g.indent_blankline_show_current_context = true
  vim.g.indent_blankline_context_patterns = {
    "class",
    "function",
    "method",
    "block",
    "list_literal",
    "selector",
    "^if",
    "^table",
    "if_statement",
    "while",
    "for"
  }
end
