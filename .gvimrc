set columns=100
set lines=32
set number
set encoding=utf8
"set guifont=Osaka-Mono:h16
"set termencoding=japan

set imd
set go-=T

"if exists('&macatsui')
"	set nomacatsui
"endif
"
"if has('kaoriya')
"	set iminsert=0 imsearch=0
"endif
autocmd BufReadPost * tab ball
colorscheme twilight

