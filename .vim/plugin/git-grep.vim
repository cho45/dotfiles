if exists("g:loaded_gitgrep")
	finish
endif
let g:loaded_gitgrep = 1


function! s:GitGrep(...)
	let args = ['git', 'grep', '-n']
	let args += a:000

	cgetexpr system(join(args, ' '))
	"silent exec 'cwin'
	exec 'FufQuickfix'
endfunction


command! -nargs=* -complete=file GG :call s:GitGrep(<f-args>)
