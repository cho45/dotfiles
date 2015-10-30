runtime! ftplugin/xml.vim

augroup AutoReloadHTML
	au!
	autocmd BufUnload,FileWritePost,BufWritePost * call <SID>AutoReloadHTML()
augroup END

function! s:AutoReloadHTML(...)
	" Check enable
	if !exists('g:autoReload') || g:autoReload == 0
		return
	endif
	silent exe "!autotesthtml.rb > /dev/null 2>&1 &"
endfunction

setlocal dictionary=~/.vim/dict/html.dict
setlocal dictionary+=~/.vim/dict/css.dict
setlocal iskeyword+=-,:

setlocal path+=templates,static
setlocal includeexpr=substitute(v:fname,'^\\/','','')
