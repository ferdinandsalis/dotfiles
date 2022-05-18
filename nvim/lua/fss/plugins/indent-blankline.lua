return function()
  require('indent_blankline').setup({
    char = '┊', -- ┆ ┊ 
    context_char = '│', -- ┆ ┊ 
    show_foldtext = false,
    show_first_indent_level = true,
    show_current_context = true,
    show_current_context_start = false,
    show_current_context_start_on_current_line = false,
    filetype_exclude = {
      'neo-tree-popup',
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
  })
end
