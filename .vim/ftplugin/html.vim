runtime! ftplugin/xml.vim
set ft=xml

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

set dictionary=~/.vim/dict/html.dict
set dictionary+=~/.vim/dict/css.dict
set iskeyword+=-,:
