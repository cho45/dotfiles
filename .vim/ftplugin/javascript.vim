nnoremap vam $?\%(.*//.*function\)\@!function<CR>f{%V%0
setlocal dictionary=~/.vim/dict/javascript.dict

let b:surround_84  = "try {\r} catch (e) { alert(e) }\n"

setlocal nocindent

iabbr my var
iabbr sub function
iabbr def function

