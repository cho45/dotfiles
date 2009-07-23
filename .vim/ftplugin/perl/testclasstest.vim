
if exists("g:perl_test_class_test")
  finish
endif
let g:perl_test_class_test = 1


function! s:PerlTestClassMethodRun()
  let re = '\vsub\s+(\w+)\s*:\s*Test'
  let line = search(re, 'bn')
  if line
    let res = matchlist(getline(line), re)
    execute '!TEST_METHOD="' . res[1] . '" /usr/bin/env perl -MP -w %'
  endif
endfunction

nmap ,t :call <SID>PerlTestClassMethodRun()<CR>

