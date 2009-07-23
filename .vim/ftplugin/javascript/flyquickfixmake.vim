" require spidermonkey
setlocal makeprg=$HOME/.vim/vimparse.js\ %\ $*
setlocal errorformat=%f:%l:%m
setlocal shellpipe=>

if !exists("g:javascript_flyquickfixmake")
	let g:javascript_flyquickfixmake = 1
	au BufWritePost *.js silent make
endif

