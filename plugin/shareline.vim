scriptencoding utf-8

if exists('g:loaded_shareline')
    finish
endif
let g:loaded_shareline = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? -range 
    \ -complete=customlist,shareline#complete
    \ ShareLine :<line1>,<line2>call shareline#yank(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
