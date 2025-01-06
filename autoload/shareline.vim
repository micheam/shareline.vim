scriptencoding utf-8

if !exists('g:loaded_shareline')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

function! s:get_repos_url(remote) abort
  let https = matchstr(a:remote, '^https://github\.com')
  if !empty(https)
    return substitute(a:remote, '\.git$', '', '')
  endif

  let git = matchstr(a:remote, '^git@github\.com')
  if !empty(git)
    return "https://github.com/" . substitute(substitute(a:remote, '\.git$', '', ''), '^git@github\.com:', '', '')
  endif

  let ssh = matchstr(a:remote, '^ssh://git@github.com')
  if !empty(ssh)
    return "https://github.com" . substitute(substitute(a:remote, '.git$', '', ''), '^ssh://git@github.com', '', '')
  endif

  throw "This remote is not Github repos [".a:remote."]"
endfunction

function! s:get_path() abort
  let root_path = substitute(system('git rev-parse --show-toplevel'), '\n\+$', '', '')
  return substitute(expand("%:p"), '^' . root_path . '/', '', '')
endfunction

function! s:get_url() abort
   let remote = substitute(system('git remote get-url origin'), '\n\+$', '', '')
   let commit = substitute(system('git show -s --format=%H'), '\n\+$', '', '')
   let repos = s:get_repos_url(remote)
   let path = s:get_path()
   return repos . "/blob/" . commit . "/" . path
endfunction

function! shareline#complete(A, L, P) abort
    let l:remote_branches = systemlist('git branch -r --format="%(refname:short)" 2>/dev/null')
    if v:shell_error != 0
        return []
    endif
    return filter(l:remote_branches, 'v:val =~# "/"')->filter('v:val =~ "^" . a:A')
endfunction

function! shareline#yank(remote_branch) range
  if empty(a:remote_branch)
    let line = a:firstline == a:lastline ? "#L" . line(".") : "#L" . a:firstline . "-L" . a:lastline
    let url = s:get_url() . line
    exec "let @+ = url"
    echo "yank " . url
    return
  endif

  if a:remote_branch !~# '^.*/.*$'
    throw "Invalid argument: '" . a:remote_branch . "'. Expected format: 'remote/branch'"
  endif
  let remote = split(a:remote_branch, '/')[0]
  let branch = split(a:remote_branch, '/')[1:]->join('/')

  let remote_url = substitute(system('git remote get-url ' . remote), '\n\+$', '', '')
  if v:shell_error != 0 || empty(remote_url)
    throw "Failed to get remote URL for remote: " . remote
  endif

  let repos_url = s:get_repos_url(remote_url)
  let path = s:get_path()
  let line = a:firstline == a:lastline ? "#L" . line(".") : "#L" . a:firstline . "-L" . a:lastline
  let url = repos_url . "/blob/" . branch . "/" . path . line
  exec "let @+ = url"
  echo "yank " . url
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
