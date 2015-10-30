" File: after/plugin/ctrlp.vim
" Description: Custom statusline example

" Make sure ctrlp is installed and loaded
if !exists('g:loaded_ctrlp') || ( exists('g:loaded_ctrlp') && !g:loaded_ctrlp )
	fini
en


" ctrlp only looks for this
let g:ctrlp_status_func = {
	\ 'main': 'CtrlP_Statusline_1',
	\ 'prog': 'CtrlP_Statusline_2',
	\ }


" CtrlP_Statusline_1 and CtrlP_Statusline_2 both must return a full statusline
" and are accessible globally.

" Arguments: focus, byfname, s:regexp, prv, item, nxt, marked
"            a:1    a:2      a:3       a:4  a:5   a:6  a:7
fu! CtrlP_Statusline_1(...)
	let focus = '%#LineNr# '.a:1.' %*'
	let byfname = '%#Character# '.a:2.' %*'
	let regex = a:3 ? '%#LineNr# regex %*' : ''
	let prv = ' <'.a:4.'>='
	let item = '{%#Character# '.a:5.' %*}'
	let nxt = '=<'.a:6.'>'
	let marked = ' '.a:7.' '
	let dir = '%<%#LineNr# '.getcwd().' %*'
	" Return the full statusline
	return dir." %= ".focus.byfname.regex.prv.item.nxt.marked
endf

" Argument: len
"           a:1
fu! CtrlP_Statusline_2(...)
	let len = '%#Function# '.a:1.' %*'
	let dir = ' %=%<%#LineNr# '.getcwd().' %*'
	" Return the full statusline
	return len.dir
endf
