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

let g:changelog_timeformat = "%Y-%m-%d"
let g:changelog_username   = "SATOH Hiroh <cho45@lowreal.net>"
let g:changelog_date_end_entry_search = '^\s*$'

let g:Perl_AuthorName      = 'cho45'
let g:Perl_AuthorRef       = ''
let g:Perl_Email           = 'cho45@lowreal.net'
let g:Perl_Company         = ''

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
set fileencodings=utf-8,euc-jp,iso-2022-jp

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

nnoremap <C-c>  :<C-u>close<CR>
nnoremap <C-d>  :<C-u>buffer # \| bwipe #<CR>

" encoding
nnoremap <silent> eu :set fenc=utf-8<CR>
nnoremap <silent> ee :set fenc=euc-jp<CR>
nnoremap <silent> es :set fenc=cp932<CR>

" encode reopen encoding
nnoremap <silent> eru :e ++enc=utf-8 %<CR>
nnoremap <silent> ere :e ++enc=euc-jp %<CR>
nnoremap <silent> ers :e ++enc=cp932 %<CR>
nnoremap <silent> err :e %<CR>

"for yanktmp.vim
noremap <silent> sy :call YanktmpYank()<CR>
noremap <silent> sp :call YanktmpPaste_p()<CR>
noremap <silent> sP :call YanktmpPaste_P()<CR>

"pasteboard 
noremap <silent> sY :call YankPB()<CR>
function! YankPB() range
	let @* = join(getline(a:firstline, a:lastline), "\n")
endfunction

" redraw map
nnoremap <silent> sr :redraw!<CR>

nnoremap <silent> eo :e %:h<CR>
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

" execute script
nnoremap ,e :call ShebangExecute()<CR>

" insert timestamp
nnoremap tw :exe "normal! i" . strftime("%Y-%m-%d\T%H:%M:%S+09:00")<CR>

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


let g:fuf_modesDisable = ['mrucmd']
let g:fuf_file_exclude = '\v\~$|\.(o|exe|bak|swp|gif|jpg|png)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])'
let g:fuf_mrufile_exclude = '\v\~$|\.bak$|\.swp|\.howm$|\.(gif|jpg|png)$'
let g:fuf_mrufile_maxItem = 500
let g:fuf_enumeratingLimit = 50
let g:fuf_keyPreview = '<C-]>'
let g:fuf_previewHeight = 0
let g:fuf_openat = 'bottom'

nmap bg :FufBuffer<CR>
nmap bG :FufFile <C-r>=expand('%:~:.')[:-1-len(expand('%:~:.:t'))]<CR><CR>
nmap gb :call fuf#givenfile#launch('', 0, 'x ', split(system('git ls-files'), '\n'))<CR>
nmap br :FufMruFile<CR>
nmap bq :FufQuickfix<CR>
nmap bl :FufLine<CR>
nnoremap <silent> <C-]> :FufTag! <C-r>=expand('<cword>')<CR><CR> 

nnoremap <unique> g/ :exec ':vimgrep /' . getreg('/') . '/j %\|cwin'<CR>
nnoremap ga :silent exec ':Ack ' . substitute(getreg('/'), '\v\\\<(.*)\\\>', "\\1", '')<CR>

function! ShebangExecute()
	let m = matchlist(getline(1), '#!\(.*\)')
	if(len(m) > 2)
		execute '!'. m[1] . ' %'
	else
		execute '!' &ft ' %'
	endif
endfunction

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

autocmd BufWritePost * if getline(1) =~ "^#!" | exe "silent !chmod +x %" | endif
autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | silent! exe '!echo -n "k%\\"' | endif

autocmd BufEnter * set nowrap
autocmd BufNewFile,BufRead *.go set filetype=go
autocmd FileType go setlocal sw=4 ts=4 sts=4 noet
autocmd FileType go setlocal makeprg=go\ build\ ./... errorformat=%f:%l:\ %m
autocmd FileType ruby setlocal sw=4 ts=4 sts=4
autocmd FileType yaml setlocal expandtab ts=2 sw=2 enc=utf-8 fenc=utf-8
autocmd BufNewFile,BufRead *.io set filetype=io
autocmd BufNewFile,BufRead *.scala set filetype=scala
autocmd BufNewFile,BufRead *.tt set filetype=html
autocmd BufNewFile,BufRead *.tx set filetype=html
autocmd BufNewFile,BufRead *.html set filetype=html
autocmd BufNewFile,BufRead *.t set filetype=perl
autocmd BufNewFile,BufRead *.psgi set filetype=perl
autocmd BufNewFile,BufRead COMMIT_EDITMSG set filetype=git fenc=utf-8

autocmd BufNewFile,BufRead */Hatena*/*.{html,tt} set ft=html | setlocal softtabstop=2 tabstop=2 shiftwidth=2
autocmd BufNewFile,BufRead */Hatena* setlocal expandtab

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
" autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

autocmd BufWritePost */debuglet.js silent! execute '!ruby ' . $HOME . '/bin/debuglet.rb %'
autocmd BufNewFile */debuglet.js silent! execute 'r!ruby ' . $HOME . '/bin/debuglet.rb'

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

command! -nargs=* -range GitBrowseRemote !git browse-remote --rev -L<line1>,<line2> <f-args> -- %

