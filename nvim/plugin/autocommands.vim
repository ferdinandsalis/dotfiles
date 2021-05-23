function! s:smart_close()
  if winnr('$') != 1
    close
  endif
endfunction

function s:setup_smart_close() abort
  let filetypes = [
        \ "help",
        \ "git-status",
        \ "git-log",
        \ "gitcommit",
        \ "dbui",
        \ "fugitive",
        \ "fugitiveblame",
        \ "LuaTree",
        \ "log",
        \ "tsplayground",
        \ "qf"
        \]
  let buftypes = ['nofile']
  let is_readonly = (&readonly || !&modifiable) && !hasmapto('q', 'n')
  if index(filetypes, &ft) >= 0 || is_readonly || &previewwindow || index(buftypes, &bt) >= 0
    nnoremap <buffer><nowait><silent> q :<C-u>call <sid>smart_close()<CR>
  endif
endfunction

augroup external_commands
  " Open images in an image viewer (probably Preview)
  autocmd BufEnter *.png,*.jpg,*.gif exec "silent !".g:open_command." ".expand("%") | :bw
augroup END

" Smart Close {{{
augroup SmartClose
  au!
  " Auto open grep quickfix window
  autocmd QuickFixCmdPost *grep* cwindow
  " Close certain filetypes by pressing q.
  autocmd FileType * call <SID>setup_smart_close()
  " Close quick fix window if the file containing it was closed
  autocmd BufEnter * if (winnr('$') == 1 && &buftype ==# 'quickfix')
        \ | bd! | endif
  " automatically close corresponding loclist when quitting a window
  if exists('##QuitPre')
    autocmd QuitPre * nested if &filetype !=# 'qf' | silent! lclose | endif
  endif
augroup END

function! s:smart_close()
  if winnr('$') != 1
    close
  endif
endfunction

augroup CheckOutsideTime "{{{1
  autocmd!
  " automatically check for changed files outside vim
  autocmd WinEnter,BufWinEnter,BufWinLeave,BufRead,BufEnter,FocusGained * silent! checktime
augroup end

augroup config_filetype_settings "{{{1
  autocmd!
  autocmd BufRead,BufNewFile .eslintrc,.stylelintrc,.babelrc set filetype=json
  " set filetype all variants of .env files
  autocmd BufRead,BufNewFile .env.* set filetype=sh
augroup END

function s:should_show_cursorline() abort
  return &buftype !=? 'terminal' && &ft != ''
endfunction

augroup Cursorline
  autocmd!
  autocmd BufEnter * if s:should_show_cursorline() | setlocal cursorline | endif
  autocmd BufLeave * setlocal nocursorline
augroup END

let s:save_excluded = ['lua.luapad']
function s:can_save() abort
  return empty(&buftype)
        \ && !empty(&filetype)
        \ && &modifiable
        \ && index(s:save_excluded, &ft) == -1
endfunction

augroup Utilities "{{{1
  autocmd!

  " source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
  autocmd BufReadCmd file:///* exe "bd!|edit ".substitute(expand("<afile>"),"file:/*","","")
  " Surprisingly enough vim has added this to defaults.vim in vim8 but this
  " is not standard behaviour still in neovim
  if has('nvim')
  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
    autocmd BufReadPost *
          \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
          \   exe "keepjumps normal g`\"" |
          \ endif
  endif

  autocmd FileType gitcommit,gitrebase set bufhidden=delete

  if exists('*mkdir') "auto-create directories for new files
    autocmd BufWritePre,FileWritePre * silent! call mkdir(expand('<afile>:p:h'), 'p')
  endif

  " Save a buffer when we leave it
  autocmd BufLeave * if s:can_save() | silent! update | endif

  " Update filetype on save if empty
  autocmd BufWritePost * nested
        \ if &l:filetype ==# '' || exists('b:ftdetect')
        \ |   unlet! b:ftdetect
        \ |   filetype detect
        \ |   echom 'Filetype set to ' . &ft
        \ | endif

  autocmd Syntax * if 5000 < line('$') | syntax sync minlines=200 | endif
augroup END

