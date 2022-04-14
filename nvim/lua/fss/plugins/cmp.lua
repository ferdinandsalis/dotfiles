return function()
  local cmp = require 'cmp'
  local h = require 'fss.highlights'
  local t = fss.replace_termcodes
  local border = fss.style.current.border

  local keyword_fg = h.get_hl('Keyword', 'fg')
  h.plugin(
    'Cmp',
    {
      'CmpItemAbbr',
      {
        foreground = 'fg',
        background = 'NONE',
        italic = false,
        bold = false,
      },
    },
    { 'CmpItemMenu', { inherit = 'NonText', italic = false, bold = false } },
    { 'CmpItemAbbrMatch', { foreground = keyword_fg } },
    { 'CmpItemAbbrDeprecated', { strikethrough = true, inherit = 'Comment' } },
    { 'CmpItemAbbrMatchFuzzy', { italic = true, foreground = keyword_fg } }
  )

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

  cmp.setup {
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
      ['<c-h>'] = cmp.mapping(function()
        vim.api.nvim_feedkeys(vim.fn['copilot#Accept'](t '<Tab>'), 'n', true)
      end),
      ['<Tab>'] = cmp.mapping(tab, { 'i', 'c' }),
      ['<S-Tab>'] = cmp.mapping(shift_tab, { 'i', 'c' }),
      ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-q>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
    },
    formatting = {
      deprecated = true,
      fields = { 'kind', 'abbr', 'menu' },
      format = function(entry, vim_item)
        vim_item.kind = fss.style.lsp.kinds[vim_item.kind]
        local name = entry.source.name
        local menu = ({
          nvim_lsp = '[Lsp]',
          nvim_lua = '[Lua]',
          emoji = '[Emoji]',
          path = '[Path]',
          calc = '[Calc]',
          neorg = '[Neorg]',
          luasnip = '[Luasnip]',
          buffer = '[Buffer]',
          spell = '[Spell]',
          cmdline = '[Command]',
        })[name]

        vim_item.menu = menu
        return vim_item
      end,
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'spell' },
    }, {
      { name = 'fuzzy_buffer' },
    }),
  }

  cmp.setup.filetype('NeogitCommitMessage', {
    sources = cmp.config.sources({
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'spell' },
      -- { name = 'cmp_git' },
    }, {
      { name = 'buffer' },
    }),
  })

  cmp.setup.filetype('norg', {
    sources = cmp.config.sources({
      { name = 'neorg' },
    }, {
      { name = 'buffer' },
    }),
  })

  local search_sources = {
    sources = cmp.config.sources({
      { name = 'nvim_lsp_document_symbol' },
    }, {
      { name = 'fuzzy_buffer' },
    }),
  }

  cmp.setup.cmdline('/', search_sources)
  cmp.setup.cmdline('?', search_sources)
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources {
      { name = 'cmdline', keyword_pattern = [=[[^[:blank:]\!]*]=] },
    },
  })
end
