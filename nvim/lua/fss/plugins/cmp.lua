return function()
  local cmp = require('cmp')
  local fmt = string.format
  local fn = vim.fn
  local api = vim.api
  local h = require('fss.highlights')
  local t = fss.replace_termcodes
  local border = fss.style.current.border

  local keyword_fg = h.get_hl('Keyword', 'fg')
  local faded = h.alter_color(h.get_hl('Comment', 'fg'), -8)

  h.plugin('Cmp', {
    CmpItemAbbr = { foreground = 'fg', background = 'NONE', italic = false, bold = false },
    CmpItemMenu = { foreground = faded, italic = true, bold = false },
    CmpItemAbbrMatch = { foreground = keyword_fg },
    CmpItemAbbrDeprecated = { strikethrough = true, inherit = 'Comment' },
    CmpItemAbbrMatchFuzzy = { italic = true, foreground = keyword_fg },
  })

  local function tab(fallback)
    local ok, luasnip = fss.safe_require('luasnip', { silent = true })
    if cmp.visible() then
      cmp.select_next_item()
    elseif ok and luasnip.expand_or_locally_jumpable() then
      luasnip.expand_or_jump()
    else
      fallback()
    end
  end

  local function shift_tab(fallback)
    local ok, luasnip = fss.safe_require('luasnip', { silent = true })
    if cmp.visible() then
      cmp.select_prev_item()
    elseif ok and luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  end

  local cmp_window = {
    border = border,
    winhighlight = table.concat({
      'Normal:NormalFloat',
      'FloatBorder:FloatBorder',
      'CursorLine:Visual',
      'Search:None',
    }, ','),
  }

  cmp.setup({
    preselect = cmp.PreselectMode.None,
    window = {
      completion = cmp.config.window.bordered(cmp_window),
      documentation = cmp.config.window.bordered(cmp_window),
    },
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    mapping = {
      ['<Tab>'] = cmp.mapping(tab, { 'i', 's', 'c' }),
      ['<S-Tab>'] = cmp.mapping(shift_tab, { 'i', 's', 'c' }),
      ['<c-h>'] = cmp.mapping(function()
        api.nvim_feedkeys(fn['copilot#Accept'](t('<Tab>')), 'n', true)
      end),
      ['<C-q>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }), -- If nothing is selected don't complete
    },
    formatting = {
      deprecated = true,
      fields = { 'abbr', 'kind', 'menu' },
      format = function(entry, vim_item)
        vim_item.kind = fmt('%s %s', vim_item.kind, fss.style.lsp.kinds[vim_item.kind])
        local menu = ({
          nvim_lsp = '[LSP]',
          nvim_lua = '[LUA]',
          emoji = '[E]',
          path = '[P]',
          calc = '[C]',
          neorg = '[N]',
          luasnip = '[SN]',
          buffer = '[B]',
          dictionary = '[D]',
          spell = '[SP]',
          cmdline = '[CMD]',
          rg = '[RG]',
          git = '[GIT]',
        })[entry.source.name]

        vim_item.menu = menu
        return vim_item
      end,
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'rg' },
      { name = 'path' },
      { name = 'spell' },
    }, {
      {
        name = 'buffer',
        options = {
          get_bufnrs = function()
            local bufs = {}
            for _, win in ipairs(api.nvim_list_wins()) do
              bufs[api.nvim_win_get_buf(win)] = true
            end
            return vim.tbl_keys(bufs)
          end,
        },
      },
      { name = 'spell' },
    }),
  })

  local search_sources = {
    view = { entries = { name = 'custom', selection_order = 'near_cursor' } },
    sources = cmp.config.sources({
      { name = 'nvim_lsp_document_symbol' },
    }, {
      { name = 'buffer' },
    }),
  }

  cmp.setup.cmdline('/', search_sources)
  cmp.setup.cmdline('?', search_sources)
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'cmdline', keyword_pattern = [=[[^[:blank:]\!]*]=] },
      { name = 'path' },
    }),
  })
end
