" * ~ end block
nnoremap vab 0/end<CR>%V%0
" def ~ end block
nnoremap vam $?\%(.*#.*def\)\@!def<CR>%V%0
" class ~ end block
nnoremap vac $?\%(.*#.*class\)\@!class<CR>%V%0
" module ~ end block
nnoremap vaM $?\%(.*#.*module\)\@!module<CR>%V%0

"nnoremap <buffer> <silent> K :Refe <cword><CR>
"nnoremap <buffer> <silent> <C-K> :Refe<CR>
set dictionary=~/.vim/dict/ruby.dict
set iskeyword+=@,$,?,:
set iskeyword-=.
