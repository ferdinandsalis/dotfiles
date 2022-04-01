----------------------------------------------------------------------------------------------------
-- Styles
----------------------------------------------------------------------------------------------------
-- Consistent store of various UI items to reuse throughout my config

local palette = {
  none = 'NONE',
  bg = '#24283b',
  bg_dark = '#1f2335',
  bg_popup = '#1f2335',
  bg_float = '#1f2335',
  bg_highlight = '#292e42',
  bg_statusline = '#292e42',
  terminal_black = '#414868',
  fg = '#c0caf5',
  fg_dark = '#a9b1d6',
  fg_sidebar = '#a9b1d6',
  fg_gutter = '#3b4261',
  comment = '#565f89',
  git = {
    change = '#6183bb',
    add = '#449dab',
    delete = '#914c54',
    conflict = '#bb7a61',
  },
  gitSigns = {
    add = '#164846',
    change = '#394b70',
    delete = '#823c41',
  },
  dark3 = '#545c7e',
  dark5 = '#737aa2',
  blue0 = '#3d59a1',
  blue = '#7aa2f7',
  cyan = '#7dcfff',
  blue1 = '#2ac3de',
  blue2 = '#0db9d7',
  blue5 = '#89ddff',
  blue6 = '#B4F9F8',
  blue7 = '#394b70',
  magenta = '#bb9af7',
  magenta2 = '#ff007c',
  purple = '#9d7cd8',
  orange = '#ff9e64',
  yellow = '#e0af68',
  green = '#9ece6a',
  green1 = '#73daca',
  green2 = '#41a6b5',
  teal = '#1abc9c',
  red = '#f7768e',
  red1 = '#db4b4b',
}

local icons = {
  lsp = {
    error = ' ',
    warn = ' ',
    hint = ' ',
    info = ' ',
  },
  git = {
    add = '', -- '',
    mod = '', -- '',
    remove = '', --
    ignore = '',
    rename = '',
    diff = '',
    repo = '',
  },
  documents = {
    file = '',
    files = '',
    folder = '',
    open_folder = '',
  },
  type = {
    array = '',
    number = '',
    object = '',
  },
  misc = {
    up = '⇡',
    down = '⇣',
    line = 'ℓ', -- ''
    indent = 'Ξ',
    tab = '⇥',
    bug = '', -- 'ﴫ'
    question = '',
    lock = '',
    circle = '',
    project = '',
    dashboard = '',
    history = '',
    comment = '',
    robot = 'ﮧ',
    lightbulb = '',
    search = '',
    code = '',
    telescope = '',
    gear = '',
    package = '',
    list = '',
    sign_in = '',
    check = '',
    fire = '',
    note = '',
    bookmark = '',
    pencil = '',
    tools = '',
    chevron_right = '',
    double_chevron_right = '»',
    table = '',
    calendar = '',
    block = '▌',
  },
}

local lsp = {
  colors = {
    error = palette.red1,
    warn = palette.orange,
    hint = palette.yellow,
    info = palette.teal,
  },
  kind_highlights = {
    Text = 'String',
    Method = 'Method',
    Function = 'Function',
    Constructor = 'TSConstructor',
    Field = 'Field',
    Variable = 'Variable',
    Class = 'Class',
    Interface = 'Constant',
    Module = 'Include',
    Property = 'Property',
    Unit = 'Constant',
    Value = 'Variable',
    Enum = 'Type',
    Keyword = 'Keyword',
    File = 'Directory',
    Reference = 'PreProc',
    Constant = 'Constant',
    Struct = 'Type',
    Snippet = 'Label',
    Event = 'Variable',
    Operator = 'Operator',
    TypeParameter = 'Type',
  },
  kinds = {
    Text = '',
    Method = '',
    Function = '',
    Constructor = '',
    Field = '', -- '',
    Variable = '', -- '',
    Class = '', -- '',
    Interface = '',
    Module = '',
    Property = 'ﰠ',
    Unit = '塞',
    Value = '',
    Enum = '',
    Keyword = '', -- '',
    Snippet = '', -- '', '',
    Color = '',
    File = '',
    Reference = '', -- '',
    Folder = '',
    EnumMember = '',
    Constant = '', -- '',
    Struct = '', -- 'פּ',
    Event = '',
    Operator = '',
    TypeParameter = '',
  },
}

fss.style = {
  palette = palette,
  icons = icons,
  lsp = lsp,
  float = {
    blend = 0,
  },
  border = {
    line = {
      { '🭽', 'FloatBorder' },
      { '▔', 'FloatBorder' },
      { '🭾', 'FloatBorder' },
      { '▕', 'FloatBorder' },
      { '🭿', 'FloatBorder' },
      { '▁', 'FloatBorder' },
      { '🭼', 'FloatBorder' },
      { '▏', 'FloatBorder' },
    },
  },
}

----------------------------------------------------------------------------------------------------
-- Global style settings
----------------------------------------------------------------------------------------------------
-- Some styles can be tweaked here to apply globally i.e. by setting the current value for that style

fss.style.current = {
  border = fss.style.border.line
}
