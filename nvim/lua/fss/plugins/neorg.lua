return function()
  fss.nnoremap('<localleader>oc', '<Cmd>Neorg gtd capture<CR>')
  fss.nnoremap('<localleader>ov', '<Cmd>Neorg gtd views<CR>')
  require('neorg').setup({
    configure_parsers = true,
    load = {
      ['core.defaults'] = {},
      ['core.integrations.telescope'] = {},
      ['core.presenter'] = {
        config = {
          zen_mode = 'zen-mode',
        },
      },
      ['core.keybinds'] = {
        config = {
          default_keybinds = true,
          neorg_leader = '<localleader>',
          hook = function(keybinds)
            keybinds.unmap('norg', 'n', '<C-s>')
            keybinds.map_event('norg', 'n', '<C-x>', 'core.integrations.telescope.find_linkable')
          end,
        },
      },
      ['core.norg.qol.toc'] = {},
      ['core.norg.journal'] = {},
      ['core.norg.completion'] = {
        config = {
          engine = 'nvim-cmp',
        },
      },
      ['core.norg.concealer'] = {},
      ['core.norg.dirman'] = {
        config = {
          workspaces = {
            notes = '$SYNC_DIR/Neorg/notes',
            tasks = '$SYNC_DIR/Neorg/tasks',
          },
        },
      },
      ['core.gtd.base'] = {
        config = {
          workspace = 'tasks',
        },
      },
    },
  })
end
