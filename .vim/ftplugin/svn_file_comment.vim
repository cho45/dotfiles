"=============================================================================
" File: svn_file_comment.vim
" Author: Yasuhiro Matsumoto <mattn.jp@gmail.com>
" Last Change: Fri, 12 Oct 2007
" Version: 0.1
"-----------------------------------------------------------------------------
" when editing comment for 'svn commit',
"  it append svn comment like following
"
"   root/path/to/dir/docs,
"   root/path/to/dir/docs/file1.txt,
"   root/path/to/dir/docs/file2.txt,
"   root/path/to/dir/docs/file3.txt:
"   <= cursor
"   --This line, and those below, will be ignored--
"   A    docs
"   A    docs/file1.txt    
"   A    docs/file2.txt    
"   A    docs/file3.txt    
"-----------------------------------------------------------------------------

function! AppendCommitFiles()
  let lstart = search("^--", "n")
  let lend = line("$")
  if line(".") > 1 || lstart != 2
    return
  endif
  let oldlang=$LANG
  let $LANG="C"
  let lines=system("svn info")
  let $LANG=oldlang
  let url=substitute(lines, '.*\nURL: \([^\x0A]*\).*', '\1', '')
  let root=substitute(lines, '.*\nRepository Root: \([^\x0A]*\).*', '\1', '')
  if match(url, root) != 0
    return
  endif
  let basedir=substitute(strpart(url, strlen(root)), '^\/*', '', '')
  let lcur = lstart
  let lines = ""
  let mx = '^\s*[A-Z_]\{1,2\}\s\+\([^$]\+\)$'
  while lcur <= lend
    let line = getline(lcur)
    if line =~ mx
      let lines .= basedir."/".substitute(line, mx, '\1', '')."\<NL>"
    endif
    let lcur = lcur + 1
  endwhile
  let lines = substitute(lines, '\n.', ',&', 'g')
  let lines = substitute(lines, '\n$', ':&', '')
  call cursor(0)
  let value = getreg("a")
  let type = getregtype("a")
  call setreg("a", lines, "c")
  execute 'normal! "ap'
  call setreg("a", value, type)
  silent! /^$
endfunction
autocmd FileType svn call AppendCommitFiles()
