return function()
  vim.g.nvim_tree_icons = {
    default = '',
    git = {
      unstaged = '',
      staged = '',
      unmerged = '',
      renamed = '',
      untracked = '',
      deleted = '',
    },
  }

  fss.nnoremap('<c-n>', [[<cmd>NvimTreeToggle<CR>]])

  function fss.nvim_tree_os_open()
    local lib = require 'nvim-tree.lib'
    local node = lib.get_node_at_cursor()
    if node then
      vim.fn.jobstart("open '" .. node.absolute_path .. "' &", { detach = true })
    end
  end

  vim.g.nvim_tree_special_files = {}
  vim.g.nvim_tree_lsp_diagnostics = 0
  vim.g.nvim_tree_indent_markers = 1
  vim.g.nvim_tree_group_empty = 0
  vim.g.nvim_tree_git_hl = 0
  vim.g.nvim_tree_auto_close = 0 -- closes the tree when it's the last window
  vim.g.nvim_tree_follow = 1 -- show selected file on open
  vim.g.nvim_tree_width = '18%'
  vim.g.nvim_tree_width_allow_resize = 1
  vim.g.nvim_tree_disable_window_picker = 1
  vim.g.nvim_tree_update_cwd = 0
  vim.g.nvim_tree_disable_netrw = 0
  vim.g.nvim_tree_hijack_netrw = 0
  vim.g.nvim_tree_root_folder_modifier = ':t'
  vim.g.nvim_tree_ignore = { '.DS_Store', 'fugitive:', '.git', '.cache' }
  vim.g.nvim_tree_highlight_opened_files = 1
  vim.g.nvim_tree_auto_resize = 1

  local action = require('nvim-tree.config').nvim_tree_callback

  vim.g.nvim_tree_bindings = {
    { key = { '<CR>', 'o', '<2-LeftMouse>' }, cb = action 'edit' },
    { key = { '<2-RightMouse>', '<C-}>' }, cb = action 'cd' },
    { key = '<C-v>', cb = action 'vsplit' },
    { key = '<C-x>', cb = action 'split' },
    { key = '<C-t>', cb = action 'tabnew' },
    { key = '<', cb = action 'prev_sibling' },
    { key = '>', cb = action 'next_sibling' },
    { key = 'P', cb = action 'parent_node' },
    { key = '<BS>', cb = action 'close_node' },
    { key = '<S-CR>', cb = action 'close_node' },
    { key = '<Tab>', cb = action 'preview' },
    { key = 'K', cb = action 'first_sibling' },
    { key = 'J', cb = action 'last_sibling' },
    { key = 'I', cb = action 'toggle_ignored' },
    { key = 'H', cb = action 'toggle_dotfiles' },
    { key = 'R', cb = action 'refresh' },
    { key = 'a', cb = action 'create' },
    { key = 'd', cb = action 'remove' },
    { key = 'r', cb = action 'rename' },
    { key = '<C->', cb = action 'full_rename' },
    { key = 'x', cb = action 'cut' },
    { key = 'c', cb = action 'copy' },
    { key = 'w', cb = action 'cd' },
    { key = 'p', cb = action 'paste' },
    { key = 'y', cb = action 'copy_name' },
    { key = 'Y', cb = action 'copy_path' },
    { key = 'gy', cb = action 'copy_absolute_path' },
    { key = '[c', cb = action 'prev_git_item' },
    { key = '}c', cb = action 'next_git_item' },
    { key = '-', cb = action 'dir_up' },
    { key = 'q', cb = action 'close' },
    { key = 'g?', cb = action 'toggle_help' },
    { key = '<C-o>', cb = ':lua fss.nvim_tree_os_open<CR>' },
  }

  local function set_highlights()
    require('fss.highlights').all {
      { 'NvimTreeIndentMarker', { link = 'Comment' } },
      { 'NvimTreeNormal', { link = 'PanelBackground' } },
      { 'NvimTreeEndOfBuffer', { link = 'PanelBackground' } },
      { 'NvimTreeVertSplit', { link = 'PanelVertSplit' } },
      { 'NvimTreeStatusLine', { link = 'PanelSt' } },
      { 'NvimTreeStatusLineNC', { link = 'PanelStNC' } },
      { 'NvimTreeRootFolder', { gui = 'bold,italic', guifg = 'LightMagenta' } },
    }
  end

  fss.augroup('NvimTreeOverrides', {
    {
      events = { 'ColorScheme' },
      targets = { '*' },
      command = set_highlights,
    },
    {
      events = { 'FileType' },
      targets = { 'NvimTree' },
      command = set_highlights,
    },
  })
end
