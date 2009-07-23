" Author: yuichi tateno ( http://rails2u.com/ )
" Licence: MIT Licence
" VERSION: $Id: perl_use_insertion.vim 126 2007-06-05 00:15:41Z gorou $
"
if exists("g:loaded_perlusecomp")
  finish
endif
let g:loaded_perlusecomp = 1

function! s:PerlUseInsertionWord(word)
    let use = a:word
    let bline = getbufline(bufnr('%'), 1, "$")

    if s:MatchCheck(bline, use)
      return 0
    endif

    let lineIndex = s:FindInsertLineIndex(bline) - 1
    if (lineIndex < 0)
      return 0
    endif

    call append(lineIndex, 'use ' . use . ';')
endfunction

function! s:PerlUseInsertionCWord()
  let word = substitute(expand('<cword>'), '::\U.*$', '', '')
  call s:PerlUseInsertionWord(word)
endfunction

function! s:FindInsertLineIndex(bline)
  let regex = '^use\s\+'
  let useIndex = -1
  let lineIndex = 0

  for line in a:bline
    let lineIndex += 1
    if(match(line, regex) >= 0)
      let useIndex = lineIndex
    endif
  endfor

  return max([useIndex + 1, 1])
  "return -1
endfunction

function! s:MatchCheck(bline, use)
  let regex = '^use\s\+' . a:use . '\s\{-};'
  for line in a:bline
    if(match(line, regex) >= 0)
      return 1
    endif
  endfor
  return 0
endfunction


command! -nargs=1 PerlUseInsertionWord :call <SID>PerlUseInsertionWord("<args>")
command! PerlUseInsertionCWord :call <SID>PerlUseInsertionCWord()

