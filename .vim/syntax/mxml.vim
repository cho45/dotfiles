" Vim syntax file 
" Language: mxml

if exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'mxml'
endif

runtime! syntax/xml.vim
unlet b:current_syntax

if filereadable(expand("<sfile>:p:h")."/actionscript.vim")
unlet! b:current_syntax
 syn include @vimActionScript <sfile>:p:h/actionscript.vim
 syn region actionScript start=+<!\[CDATA\[+ end=+\]\]>+ contains=@vimActionScript
endif
