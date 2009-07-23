setlocal makeprg=ruby\ -c\ %\ $*\ >/dev/null
setlocal errorformat=%f:%l:%m
setlocal shellpipe=2>

if !exists("g:ruby_flyquickfixmake")
	let g:ruby_flyquickfixmake = 1
	au BufWritePost *.rb silent make
endif

