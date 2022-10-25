if not fss then
  return
end

-- Resources:
--- 1. https://gabri.me/blog/diy-vim-statusline
--- 2. https://github.com/elenapan/dotfiles/blob/master/config/nvim/statusline.vim
--- 3. https://got-ravings.blogspot.com/2008/08/vim-pr0n-making-statuslines-that-own.html
--- 4. Right sided truncation - https://stackoverflow.com/a/20899652

local M = {}

local H = require('fss.highlights')
local utils = require('fss.utils.statusline')
local api = vim.api
local fn = vim.fn
local icons = fss.style.icons
local C = utils.constants

local function colors()
  --- NOTE: Unicode characters including vim devicons should NOT be highlighted
  --- as italic or bold, this is because the underlying bold font is not necessarily
  --- patched with the nerd font characters
  --- terminal emulators like kitty handle this by fetching nerd fonts elsewhere
  --- but this is not universal across terminals so should be avoided

  -- local indicator_color = P.bright_blue
  -- local warning_fg = fss.style.lsp.colors.warn
  -- local error_color = fss.style.lsp.colors.error
  -- local info_color = fss.style.lsp.colors.info
  -- local normal_fg = H.get('Normal', 'fg')
  -- local string_fg = H.get('String', 'fg')
  -- local number_fg = H.get('Number', 'fg')
  local statusline_bg = H.get('StatusLine', 'bg')
  -- local dim_color = H.alter_color(normal_bg, 40)
  -- local bg_color = H.get('PanelBackground', 'bg')

  H.all({
    --   StMetadata = { background = bg_color, inherit = 'Comment' },
    --   StMetadataPrefix = { background = bg_color, foreground = { from = 'Comment' } },
    --   StIndicator = { background = bg_color, foreground = indicator_color },
    --   StModified = { foreground = string_fg, background = bg_color },
    --   Git
    { StGit = { foreground = { from = 'Normal' }, bold = true } },

    --   StGreen = { foreground = string_fg, background = bg_color },
    --   StBlue = { foreground = P.dark_blue, background = bg_color, bold = true },
    --   StNumber = { foreground = number_fg, background = bg_color },
    --   StCount = { foreground = 'bg', background = indicator_color, bold = true },
    --   StClient = { background = bg_color, foreground = normal_fg, bold = true },
    --   StDirectory = { background = bg_color, foreground = 'Gray', italic = true },
    --   StDirectoryInactive = { background = bg_color, foreground = dim_color, italic = true },
    --   StParentDirectory = { background = bg_color, foreground = string_fg, bold = true },
    --   StTitle = { background = bg_color, foreground = 'LightGray', bold = true },
    --   StComment = { background = bg_color, inherit = 'Comment' },
    --   StatusLine = { background = bg_color },
    --   StatusLineNC = { link = 'VertSplit' },
    --   StInfo = { foreground = info_color, background = bg_color, bold = true },
    --   StWarn = { foreground = warning_fg, background = bg_color },
    --   StError = { foreground = error_color, background = bg_color },
    --   StFilename = { background = bg_color, foreground = 'LightGray', bold = true },
    --   StFilenameInactive = { inherit = 'Comment', background = bg_color, bold = true },

    -- Modes
    {
      StModeNormal = {
        background = statusline_bg,
        foreground = { from = 'Function' },
        bold = true,
      },
    },
    {
      StModeInsert = {
        background = statusline_bg,
        foreground = { from = 'String' },
        bold = true,
      },
    },
    {
      StModeVisual = {
        background = statusline_bg,
        foreground = { from = 'Statement' },
        bold = true,
      },
    },
    {
      StModeReplace = {
        background = statusline_bg,
        foreground = { from = 'Substitute' },
        bold = true,
      },
    },
    {
      StModeCommand = {
        background = statusline_bg,
        foreground = { from = 'Constant' },
        bold = true,
      },
    },
    {
      StModeSelect = {
        background = statusline_bg,
        foreground = { from = '@keyword' },
        bold = true,
      },
    },

    -- Hydra
    -- HydraRedSt = { inherit = 'HydraRed', reverse = false },
    -- HydraBlueSt = { inherit = 'HydraBlue', reverse = false },
    -- HydraAmaranthSt = { inherit = 'HydraAmaranth', reverse = false },
    -- HydraTealSt = { inherit = 'HydraTeal', reverse = false },
    -- HydraPinkSt = { inherit = 'HydraPink', reverse = false },
  })
end

local separator = function()
  return { component = C.ALIGN, length = 0, priority = 0 }
end

local end_marker = function()
  return { component = C.END, length = 0, priority = 0 }
end

-- A very over-engineered statusline
-- @return string
function fss.ui.statusline()
  local win = api.nvim_get_current_win()
  local curbuf = api.nvim_win_get_buf(win)
  local component = utils.component
  local component_if = utils.component_if
  local available_space = vim.o.columns

  local ctx = {
    bufnum = curbuf,
    winid = win,
    bufname = api.nvim_buf_get_name(curbuf),
    preview = vim.wo[win].previewwindow,
    readonly = vim.bo[curbuf].readonly,
    filetype = vim.bo[curbuf].ft,
    buftype = vim.bo[curbuf].bt,
    modified = vim.bo[curbuf].modified,
    fileformat = vim.bo[curbuf].fileformat,
    shiftwidth = vim.bo[curbuf].shiftwidth,
    expandtab = vim.bo[curbuf].expandtab,
  }

  -- Modifiers
  local plain = utils.is_plain(ctx)
  -- local file_modified = utils.modified(ctx, icons.misc.circle)
  local focused = vim.g.vim_in_focus or true

  -- Setup

  local statusline = {
    -- component_if(icons.misc.block, not plain, 'StIndicator', {
    --   before = '',
    --   after = '',
    --   priority = 0,
    -- }),
    utils.spacer(2),
  }
  local add = utils.winline(statusline)

  -- Filename

  local segments = utils.file(ctx, plain)
  local dir, parent, file = segments.dir, segments.parent, segments.file
  local dir_component = component(dir.item, dir.hl, dir.opts)
  local parent_component = component(parent.item, parent.hl, parent.opts)

  local is_git_repo = fn.isdirectory(fn.getcwd(win) .. '/.git') == 1
  if is_git_repo then
    file.opts.after = ' ' .. icons.git.repo
  end
  local file_component = component(file.item, file.hl, file.opts)

  local readonly_hl =
    H.win_hl.adopt(win, 'StatusLine', 'StCustomError', 'StError')
  local readonly_component =
    component(utils.readonly(ctx), readonly_hl, { priority = 1 })

  -- Mode

  -- show a minimal statusline with only the mode and file component
  if plain or not focused then
    add(readonly_component, dir_component, parent_component, file_component)
    return utils.display(statusline, available_space)
  end

  -- Variables

  local mode, mode_hl = utils.mode()
  local lnum, col = unpack(api.nvim_win_get_cursor(win))
  local line_count = api.nvim_buf_line_count(ctx.bufnum)

  -- Git state
  local status = vim.b.gitsigns_status_dict or {}
  local updates = vim.g.git_statusline_updates or {}
  local ahead = updates.ahead and tonumber(updates.ahead) or 0
  local behind = updates.behind and tonumber(updates.behind) or 0

  -- LSP Diagnostics
  local diagnostics = utils.diagnostic_info(ctx)

  -- HYDRA
  local hydra_active, hydra = utils.hydra()

  -- Left section

  add(
    readonly_component,

    component(mode, mode_hl, {
      priority = 0,
      suffix = '', -- │
    }),

    -- component_if(
    --   utils.search_count(),
    --   vim.v.hlsearch > 0,
    --   'StCount',
    --   { priority = 1 }
    -- ),

    -- dir_component,
    -- parent_component,
    -- file_component,

    -- component_if(file_modified, ctx.modified, 'StModified', { priority = 1, before = ' ' }),

    -- Git Status
    component(status.head, 'StBlue', {
      prefix = icons.git.branch,
      prefix_color = 'StGit',
      priority = 1,
      suffix = '', -- │
    }),

    component(status.changed, 'StTitle', {
      prefix = icons.git.mod,
      prefix_color = 'StWarn',
      priority = 3,
    }),

    component(status.removed, 'StTitle', {
      prefix = icons.git.remove,
      prefix_color = 'StError',
      priority = 3,
    }),

    component(status.added, 'StTitle', {
      prefix = icons.git.add,
      prefix_color = 'StGreen',
      priority = 3,
    }),

    component(ahead, 'StTitle', {
      prefix = icons.misc.up,
      prefix_color = 'StGreen',
      before = '',
      priority = 5,
    }),

    component(behind, 'StTitle', {
      prefix = icons.misc.down,
      prefix_color = 'StNumber',
      after = ' ',
      priority = 5,
    }),

    component_if(diagnostics.error.count, diagnostics.error, 'StError', {
      prefix = diagnostics.error.icon,
      prefix_color = 'StError',
      priority = 1,
    }),

    component_if(diagnostics.warn.count, diagnostics.warn, 'StWarn', {
      prefix = diagnostics.warn.icon,
      prefix_color = 'StWarn',
      priority = 3,
    }),

    component_if(diagnostics.info.count, diagnostics.info, 'StInfo', {
      prefix = diagnostics.info.icon,
      prefix_color = 'StInfo',
      priority = 4,
    }),

    -- Local plugin dev indicator
    component_if(
      available_space > 100 and 'local dev' or '',
      vim.env.DEVELOPING ~= nil,
      'StComment',
      {
        prefix = icons.misc.tools,
        padding = 'none',
        before = '  ',
        prefix_color = 'StWarn',
        small = 1,
        priority = 2,
      }
    ),
    separator(),

    -- Middle section
    -- Neovim allows unlimited alignment sections so we can put things in the
    -- middle of our statusline - https://neovim.io/doc/user/vim_diff.html#vim-differences

    component_if(
      'Saving…',
      vim.g.is_saving,
      'StComment',
      { before = ' ', priority = 1 }
    ),

    component_if(hydra.name, hydra_active, hydra.color, {
      prefix = string.rep(' ', 5) .. '🐙',
      suffix = string.rep(' ', 5),
      priority = 5,
    }),

    -- Start of the right side layout
    separator()
  )

  -- LSP Clients

  local lsp_clients = fss.map(function(client, index)
    return component(client.name, 'StClient', {
      prefix = index == 1 and ' LSP' or nil,
      prefix_color = index == 1 and 'StMetadata' or nil,
      suffix = '', -- │
      suffix_color = 'StMetadataPrefix',
      priority = client.priority,
    })
  end, utils.lsp_clients(ctx))
  -- add(unpack(lsp_clients))

  add(
    component(
      utils.debugger(),
      'StMetadata',
      { prefix = icons.misc.bug, priority = 4 }
    ),

    -- (Unexpected) Indentation
    -- component_if(
    --   ctx.shiftwidth,
    --   ctx.shiftwidth > 2 or not ctx.expandtab,
    --   'StTitle',
    --   {
    --     prefix = ctx.expandtab and icons.misc.indent or icons.misc.tab,
    --     prefix_color = 'StatusLine',
    --     priority = 6,
    --   }
    -- ),

    -- Current line number/total line number
    component(lnum, 'StTitle', {
      after = '',
      prefix = icons.misc.line,
      prefix_color = 'StMetadataPrefix',
      priority = 7,
    }),

    -- Line count
    component(line_count, 'StComment', {
      before = '',
      prefix = '/',
      padding = { prefix = false, suffix = true },
      prefix_color = 'StComment',
      priority = 7,
    }),

    -- Current column
    component(col, 'StTitle', {
      prefix = '',
      prefix_color = 'StMetadataPrefix',
      priority = 7,
    }),

    end_marker()
  )
  -- removes 5 columns to add some padding
  return utils.display(statusline, available_space - 5)
end

fss.augroup('CustomStatusline', {
  {
    event = { 'FocusGained' },
    pattern = { '*' },
    command = function()
      vim.g.vim_in_focus = true
    end,
  },
  {
    event = { 'FocusLost' },
    pattern = { '*' },
    command = function()
      vim.g.vim_in_focus = false
    end,
  },
  {
    event = { 'VimEnter', 'ColorScheme' },
    pattern = { '*' },
    command = colors,
  },
  {
    event = { 'BufReadPre' },
    once = true,
    pattern = { '*' },
    command = utils.git_updates,
  },
  {
    event = { 'BufWritePre' },
    pattern = { '*' },
    command = function()
      if not vim.g.is_saving and vim.bo.modified then
        vim.g.is_saving = true
        vim.defer_fn(function()
          vim.g.is_saving = false
        end, 1000)
      end
    end,
  },
  {
    event = 'User',
    pattern = {
      'NeogitPushComplete',
      'NeogitCommitComplete',
      'NeogitStatusRefresh',
    },
    command = function()
      utils.git_updates_refresh()
    end,
  },
})

-- :h qf.vim, disable qf statusline
vim.g.qf_disable_statusline = 1

-- set the statusline
vim.o.statusline = '%{%v:lua.fss.ui.statusline()%}'

return M
