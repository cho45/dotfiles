
let g:autoReload = 0
command! AutoReloadToggle let g:autoReload = !g:autoReload

augroup AutoReload
	au!
	autocmd BufUnload,FileWritePost,BufWritePost * call <SID>AutoReload()
augroup END

function! s:AutoReload(...)
	" Check enable
	if !exists('g:autoReload') || g:autoReload == 0
		return
	endif
	silent exe "!Reload.rb > /dev/null 2>&1 &"
endfunction

