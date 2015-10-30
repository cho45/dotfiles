
syntax on
filetype plugin on
filetype indent on

call pathogen#runtime_append_all_bundles()
let $GOROOT = substitute(system("go env GOROOT"), "\n", "", "g")
if $GOROOT != ''
	set runtimepath+=$GOROOT/misc/vim
	exe "set runtimepath+=".globpath($GOPATH, "src/github.com/nsf/gocode/vim")
endif


"ポップアップ補完メニュー色設定（通常の項目、選択されている項目、スクロールバー、スクロールバーのつまみ部分）
highlight Pmenu ctermbg=6 guibg=#4c745a
highlight PmenuSel ctermbg=3 guibg=#d4b979
highlight PmenuSbar ctermbg=0 guibg=#333333
"highlight PmenuThumb ctermbg=0 guibg=Red

if &term =~ "xterm-256color"
	colorscheme desert256mod
endif

highlight ZenkakuSpace ctermbg=6
match ZenkakuSpace /\s\+$\|　/

set listchars=tab:>.
set list
set textwidth=1000

set directory=~/swp

let g:EclimBaseDir  = '/Users/cho45/.vim'
if !filereadable('.classpath')
	let g:EclimDisabled = 1
endif

let g:wildfire_objects = {
	\ "*" : ["i'", 'i"', "i)", "i]", "i}", "ip", "it", "at", "i>"],
\ }

let g:changelog_timeformat = "%Y-%m-%d"
let g:changelog_username   = "SATOH Hiroh <cho45@lowreal.net>"
let g:changelog_date_end_entry_search = '^\s*$'

let g:Perl_AuthorName      = 'cho45'
let g:Perl_AuthorRef       = ''
let g:Perl_Email           = 'cho45@lowreal.net'
let g:Perl_Company         = ''

let g:user_zen_expandabbr_key = '<C-E>'

let g:jpTemplateKey        = '<C-B>'

let g:netrw_preview        = 1

let g:use_xhtml = 1
let g:html_use_css = 1
let g:html_number_lines = 0

" zsh っぽい補完に
"
set wildmode=longest,list

" ちゃんと文字書いて○とか
set ambiwidth=double

" ポップアップメニューをよしなに
set completeopt=menu,preview,longest,menuone

" 補完候補の設定
set complete=.,w,b,u,k

" バックアップとか自分でしろ
set nobackup

" 誰かが編集したら読み直して
set autoread

" 袖あまりは良いものだ
set scrolloff=10000000
" 行番号の表示
set number
" デフォルトインデント設定
set autoindent smartindent
" よさげなタブ
set smarttab
set softtabstop=4 tabstop=4 shiftwidth=4
" BS の挙動
set backspace=indent,eol,start

" よしなにしてくれ
set ignorecase smartcase
" インクメンタル
set incsearch
" 最初にもどれ
set wrapscan

" 対応する括弧の表示
set showmatch
" 入力中のコマンドを表示
set showcmd

" 行頭・行末間移動を可能に
set whichwrap=b,s,h,l,<,>,[,]

" 補完候補を表示する
set wildmenu

set splitbelow

set nrformats="hex"

set undofile
set undodir=~/swp

" ステータス表示用変数
set laststatus=2
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']['.&ft.']'}\ %=\ %l,%c%V%8P

function! CharacterCount()
	redir @c
	silent exe "normal g\<C-g>"
	redir END
	return matchstr(@c, '[0-9]* of [0-9]* Chars')
endfunction

set termencoding=utf-8
set encoding=utf-8
set fileencodings=euc-jp,iso-2022-jp

set hidden

set viminfo+=!

set nowrap
set sidescroll=5
set listchars+=precedes:<,extends:>

" mapping

inoremap  <BS>
nnoremap Y y$

nnoremap j gj
nnoremap k gk
" nmap gb :ls<CR>:buf 

" sort css property (id:secondlife)
nmap gso vi{:!sortcss<CR>
vmap gso i{:!sortcss<CR>


" encoding
nmap <silent> eu :set fenc=utf-8<CR>
nmap <silent> ee :set fenc=euc-jp<CR>
nmap <silent> es :set fenc=cp932<CR>

" encode reopen encoding
nmap <silent> eru :e ++enc=utf-8 %<CR>
nmap <silent> ere :e ++enc=euc-jp %<CR>
nmap <silent> ers :e ++enc=cp932 %<CR>
nmap <silent> err :e %<CR>


"for yanktmp.vim
map <silent> sy :call YanktmpYank()<CR>
map <silent> sp :call YanktmpPaste_p()<CR>
map <silent> sP :call YanktmpPaste_P()<CR>

" redraw map
nmap <silent> sr :redraw!<CR>

nmap <silent> eo :e %:h<CR>
nnoremap e3 :s/?\s*\((.\{-1,})\\|\S\+\)\s*:\s*\((.\{-1,})\\|\S\+\)/? \2 : \1/<CR>

" nmap <silent> eg :e git:HEAD^:%<CR>
nnoremap <silent> eg :<C-u>call <SID>git_prev_rev()<CR>

function! s:git_prev_rev()
	let path = expand('%')
	let commit = "HEAD"

	let l = matchlist(path, 'git:\([^:]\+\):\([^:]\+\)')
	if len(l) > 0
		let commit = l[1]
		let path   = l[2]
	endif

	let output = system(printf("git log -n 2 --pretty=format:'%%h %%s' HEAD~100..%s -- %s",
	\                          shellescape(commit),
	\                          shellescape(path)))

	if v:shell_error != 0
		echoerr 'git log failed with the following reason:'
		echoerr output
		return
	endif

	let commits = split(output, "\n")
	if len(commits) > 1
		let prev    = commits[1]
		let [commit_id, subject] = matchlist(prev, '^\(\S*\)\s\(.*\)$')[1:2]

		let cursor = getpos(".")
		silent edit `=printf('git:%s:%s', commit_id, path)`
		call setpos('.', cursor)

		echo subject
	else
		echo 'no more revisions'
	endif
endfunction

" cmode
cmap <ESC>h <Left>
cmap <ESC>l <Right>


"if has("mac")
	map <silent> sY :call YankPB()<CR>
	function! YankPB()
		let tmp = tempname()
		call writefile(getline(a:firstline, a:lastline), tmp, 'b')
		silent exec ":!cat " . tmp . " | pbcopy"
	endfunction
"endif

" execute script
nmap ,e :call ShebangExecute()<CR>

" insert timestamp
nmap tw :exe "normal! i" . strftime("%Y-%m-%d\T%H:%M:%S+09:00")<CR>

nnoremap <C-w><C-w> <C-w><C-w>:call <SID>good_width()<CR>
nnoremap <C-w>h <C-w>h:call <SID>good_width()<CR>
nnoremap <C-w>j <C-w>j:call <SID>good_width()<CR>
nnoremap <C-w>k <C-w>k:call <SID>good_width()<CR>
nnoremap <C-w>l <C-w>l:call <SID>good_width()<CR>

function! s:good_width()
	if winwidth(0) < 120
		vertical resize 120
	endif
endfunction


highlight clear CursorLine
highlight CursorLine ctermbg=DarkGreen ctermfg=White guifg=#ffffff guibg=#000000 
highlight CtrlPMatch term=bold ctermfg=Yellow
let g:ctrlp_default_input = 1
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_map = '<Nop>'
let g:ctrlp_working_path_mode = 'c'
let g:ctrlp_open_new_file = 'r'
let g:ctrlp_extensions = ['mixed']
let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:18'
let g:ctrlp_user_command = {
	\ 'types': {
		\ 1: ['.git', 'cd %s && git ls-files'],
		\ 2: ['.hg', 'hg --cwd %s locate -I .'],
		\ },
	\ 'fallback': 'files %s'
	\ }

let g:ctrlp_prompt_mappings = {
	\ 'PrtBS()':              ['<bs>', '<c-]>'],
	\ 'PrtDelete()':          ['<del>'],
	\ 'PrtDeleteWord()':      ['<c-w>'],
	\ 'PrtClear()':           ['<c-u>'],
	\ 'PrtSelectMove("j")':   ['<c-n>', '<c-j>', '<down>'],
	\ 'PrtSelectMove("k")':   ['<c-p>', '<c-k>', '<up>'],
	\ 'PrtSelectMove("t")':   ['<Home>', '<kHome>'],
	\ 'PrtSelectMove("b")':   ['<End>', '<kEnd>'],
	\ 'PrtSelectMove("u")':   ['<PageUp>', '<kPageUp>'],
	\ 'PrtSelectMove("d")':   ['<PageDown>', '<kPageDown>'],
	\ 'PrtHistory(-1)':       [],
	\ 'PrtHistory(1)':        [],
	\ 'AcceptSelection("e")': ['<cr>', '<2-LeftMouse>'],
	\ 'AcceptSelection("h")': [],
	\ 'AcceptSelection("t")': [],
	\ 'AcceptSelection("v")': [],
	\ 'ToggleFocus()':        ['<s-tab>'],
	\ 'ToggleRegex()':        [],
	\ 'ToggleByFname()':      ['<c-d>'],
	\ 'ToggleType(1)':        ['<c-f>', '<c-up>'],
	\ 'ToggleType(-1)':       ['<c-b>', '<c-down>'],
	\ 'PrtExpandDir()':       ['<tab>'],
	\ 'PrtInsert("c")':       ['<MiddleMouse>', '<insert>'],
	\ 'PrtInsert()':          ['<c-\>'],
	\ 'PrtCurStart()':        ['<c-a>'],
	\ 'PrtCurEnd()':          ['<c-e>'],
	\ 'PrtCurLeft()':         ['<c-h>', '<left>', '<c-^>'],
	\ 'PrtCurRight()':        ['<c-l>', '<right>'],
	\ 'PrtClearCache()':      ['<F5>'],
	\ 'PrtDeleteEnt()':       ['<F7>'],
	\ 'CreateNewFile()':      ['<c-o>'],
	\ 'MarkToOpen()':         ['<c-z>'],
	\ 'OpenMulti()':          [],
	\ 'PrtExit()':            ['<esc>', '<c-c>', '<c-g>'],
	\ }

nmap bg :<C-u>CtrlPBuffer<CR>
nmap bG :<C-u>CtrlP <C-R>=expand("%:p:h") . "/" <CR><CR>
nmap gb :<C-u>CtrlPRoot<CR>

nmap <unique> g/ :exec ':vimgrep /' . getreg('/') . '/j %\|cwin'<CR>
nmap ga :silent exec ':Ack ' . substitute(getreg('/'), '\v\\\<(.*)\\\>', "\\1", '')<CR>



augroup MyAutocmd
	au!
	autocmd BufWritePost * if getline(1) =~ "^#!" | exe "silent !chmod +x %" | endif
	autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | silent! exe '!echo -n "k%\\"' | endif

	" YAML setting
	autocmd FileType yaml setlocal expandtab ts=2 sw=2 enc=utf-8 fenc=utf-8
	autocmd BufEnter * set nowrap


	" auto cd
	" autocmd BufEnter * exe ":lcd \"" . expand("%:p:h") . "\""

	" use 'encoding' if the buffer doesn't contain any multibyte character.
	autocmd BufReadPost *
				\   if &modifiable && !search('[^\x00-\x7F]', 'cnw')
				\ |   setlocal fileencoding=
				\ | endif
augroup END


function! ShebangExecute()
	let m = matchlist(getline(1), '#!\(.*\)')
	if(len(m) > 2)
		execute '!'. m[1] . ' %'
	else
		execute '!' &ft ' %'
	endif
endfunction

augroup Indent
	au!
	au BufNewFile,BufRead *yuno/* set expandtab softtabstop=4 tabstop=4 shiftwidth=4
augroup END

" {{{ Autocompletion using the TAB key

" This function determines, wether we are on the start of the line text (then tab indents) or
" if we want to try autocompletion
function! InsertTabWrapper()
	let col = col('.') - 1
	if !col || getline('.')[col - 1] !~ '\k'
		return "\<TAB>"
	else
		if pumvisible()
			return "\<C-N>"
		else
			return "\<C-N>\<C-P>"
		end
	endif
endfunction
" Remap the tab key to select action with InsertTabWrapper
inoremap <tab> <c-r>=InsertTabWrapper()<cr>

" }}} Autocompletion using the TAB key

set iminsert=0 imsearch=0

set nofoldenable
set lazyredraw
inoremap <expr> <CR> pumvisible() ? "\<C-Y>\<CR>" : "\<CR>"

let g:acp_completeOption = '.,w,b,k'
let g:acp_behavior = {
      \   'go' : [
      \     {
      \       'command' : "\<C-x>\<C-o>",
      \       'meets'   : 'acp#meetsForKeyword',
      \       'repeat'  : 0,
      \     },
      \     {
      \       'command' : "\<C-n>",
      \       'meets'   : 'acp#meetsForKeyword',
      \       'repeat'  : 0,
      \     },
      \   ],
      \   'html' : [
      \     {
      \       'command' : "\<C-n>",
      \       'meets'   : 'acp#meetsForKeyword',
      \       'repeat'  : 0,
      \     },
      \   ],
      \   'xml' : [
      \     {
      \       'command' : "\<C-n>",
      \       'meets'   : 'acp#meetsForKeyword',
      \       'repeat'  : 0,
      \     },
      \   ],
      \   'xhtml' : [
      \     {
      \       'command' : "\<C-n>",
      \       'meets'   : 'acp#meetsForKeyword',
      \       'repeat'  : 0,
      \     },
      \   ],
      \   'typescript' : [
      \     {
      \       'command' : "\<C-x>\<C-o>",
      \       'meets'   : 'acp#meetsForKeyword',
      \       'repeat'  : 0,
      \     },
      \   ],
      \ }

autocmd BufNewFile,BufRead *.go set filetype=go
autocmd FileType go setlocal sw=4 ts=4 sts=4 noet
autocmd FileType go setlocal makeprg=go\ build\ ./... errorformat=%f:%l:\ %m
autocmd FileType ruby setlocal sw=2 ts=2 sts=2
autocmd BufNewFile,BufRead *.io set filetype=io
autocmd BufNewFile,BufRead *.scala set filetype=scala
autocmd BufNewFile,BufRead *.tt set filetype=html
autocmd BufNewFile,BufRead *.tx set filetype=html
autocmd BufNewFile,BufRead *.html set filetype=xml
autocmd BufNewFile,BufRead *.t set filetype=perl
autocmd BufNewFile,BufRead *.psgi set filetype=perl
autocmd BufNewFile,BufRead COMMIT_EDITMSG set filetype=git fenc=utf-8


autocmd BufNewFile,BufRead */Hatena*/*.{html,tt} set ft=html | setlocal softtabstop=2 tabstop=2 shiftwidth=2
autocmd BufNewFile,BufRead */Hatena* setlocal expandtab

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
" autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

nnoremap <C-c>  :<C-u>close<CR>
nnoremap <C-d>  :<C-u>buffer # \| bwipe #<CR>

function! Smartchr(fallback_literal, ...)
	let args = reverse(copy(a:000))
	call add(args, a:fallback_literal)
	let args = map(args, 'type(v:val) == type("") ? [0, v:val] : v:val')

	for i in range(len(args) - 1)
		let [pattern1, literal1] = args[i]
		let [pattern2, literal2] = args[i+1]

		if pattern1 is 0
			if search('\V' . escape(literal2, '\') . '\%#', 'bcn')
				return repeat("\<BS>", len(literal2)) . literal1
			endif
		else
			throw 'FIXME: pattern is not implemented yet: ' . string(args[i])
		endif
	endfor

	return a:fallback_literal
endfunction


iabbr slef self
iabbr sefl self
iabbr tihs this
iabbr thsi this
iabbr crete create
iabbr funciton function

augroup AutoMkdir
	function! s:auto_mkdir(dir, force)
		if !isdirectory(a:dir) && (a:force || input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
			call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
		endif
	endfunction

	autocmd!
	autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
augroup END

autocmd BufWritePost */debuglet.js silent! execute '!ruby ' . $HOME . '/bin/debuglet.rb %'
autocmd BufNewFile */debuglet.js silent! execute 'r!ruby ' . $HOME . '/bin/debuglet.rb'

function! GitWeb()
	let git_output = substitute(system('git config --get remote.origin.url'), '\n*$', '', '')
	let repos = substitute(git_output, '^.*:\|\.git$', '', 'g')
	let commit = substitute(system('git name-rev --name-only HEAD'), '\n*$', '', '')

	let url = 'open ' . $GITWEB_BASE . repos . '/blob/' . commit . '/' . expand('%') . '#l' . line('.')
	echo url
	call system(url)
endfunction
command! GitWeb call GitWeb()

command! -nargs=* -range GitBrowseRemote !git browse-remote --rev -L<line1>,<line2> <f-args> -- %

