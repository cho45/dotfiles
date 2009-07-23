
nmap epd i<CR>use Data::Dumper;<CR>warn Dumper <ESC>pa;<CR><ESC>
vmap epd yi<CR>use Data::Dumper;<CR>warn Dumper <ESC>pa;<CR><ESC>
nmap <silent> <buffer> em :PerlUseInsertionCWord<CR>
nnoremap epp a<C-R>=join(split(substitute(expand("%:p"), '.*lib/\\|.pm$', "", "g"), "/"), "::")<CR>
vnoremap <silent> <Space>a :Align =><CR>


