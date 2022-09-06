return function()
  local cwd = vim.fn.getcwd()
  require('gitsigns').setup({
    _threaded_diff = true,
    _extmark_signs = true,
    signs = {
      add = { hl = 'GitSignsAdd', text = '▌' },
      change = { hl = 'GitSignsChange', text = '▌' },
      delete = { hl = 'GitSignsDelete', text = '▌' },
      topdelete = { hl = 'GitSignsDelete', text = '▌' },
      changedelete = { hl = 'GitSignsChange', text = '▌' },
    },
    word_diff = false,
    current_line_blame = not cwd:match('personal') and not cwd:match(
      'dotfiles'
    ),
    numhl = false,
    preview_config = {
      border = fss.style.current.border,
    },
    on_attach = function()
      local gs = package.loaded.gitsigns

      local function qf_list_modified()
        gs.setqflist('all')
      end

      fss.nnoremap('<leader>hu', gs.undo_stage_hunk, 'undo stage')
      fss.nnoremap('<leader>hp', gs.preview_hunk, 'preview current hunk')
      fss.nnoremap('<leader>hs', gs.stage_hunk, 'stage current hunk')
      fss.nnoremap('<leader>hr', gs.reset_hunk, 'reset current hunk')
      fss.nnoremap(
        '<leader>hb',
        gs.toggle_current_line_blame,
        'toggle current line blame'
      )
      fss.nnoremap('<leader>hd', gs.toggle_deleted, 'show deleted lines')
      fss.nnoremap(
        '<leader>hw',
        gs.toggle_word_diff,
        'gitsigns: toggle word diff'
      )
      fss.nnoremap(
        '<localleader>gw',
        gs.stage_buffer,
        'gitsigns: stage entire buffer'
      )
      fss.nnoremap(
        '<localleader>gre',
        gs.reset_buffer,
        'gitsigns: reset entire buffer'
      )
      fss.nnoremap(
        '<localleader>gbl',
        gs.blame_line,
        'gitsigns: blame current line'
      )
      fss.nnoremap(
        '<leader>lm',
        qf_list_modified,
        'gitsigns: list modified in quickfix'
      )

      -- Navigation
      fss.nnoremap('[h', function()
        vim.schedule(function()
          gs.next_hunk()
        end)
        return '<Ignore>'
      end, { expr = true, desc = 'go to next git hunk' })

      fss.nnoremap(']h', function()
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return '<Ignore>'
      end, { expr = true, desc = 'go to previous git hunk' })

      fss.vnoremap('<leader>hs', function()
        gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end)
      fss.vnoremap('<leader>hr', function()
        gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end)

      vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end,
  })
end
