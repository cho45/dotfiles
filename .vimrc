
syntax on
filetype plugin on
filetype indent on

call pathogen#runtime_append_all_bundles()

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

set directory=~/swp

let g:EclimBaseDir  = '/Users/cho45/.vim'
if !filereadable('.classpath')
	let g:EclimDisabled = 1
endif

let g:hatena_user          = 'cho45'
let g:hatena_group_name    = 'subtech'

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
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']['.&ft.']'}\ %=%{GitBranch()}\ %l,%c%V%8P

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

let g:fuf_modesDisable = ['mrucmd']
let g:fuf_file_exclude = '\v\~$|\.(o|exe|bak|swp|gif|jpg|png)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])'
let g:fuf_mrufile_exclude = '\v\~$|\.bak$|\.swp|\.howm$|\.(gif|jpg|png)$'
let g:fuf_mrufile_maxItem = 500
let g:fuf_enumeratingLimit = 50
let g:fuf_keyPreview = '<C-]>'
let g:fuf_previewHeight = 0

nmap bg :FufBuffer<CR>
nmap bG :FufFile <C-r>=expand('%:~:.')[:-1-len(expand('%:~:.:t'))]<CR><CR>
"nmap gb :FufFile<CR>
nmap gb :FufFile **/<CR>
nmap br :FufMruFile<CR>
nmap bq :FufQuickfix<CR>
nmap bl :FufLine<CR>
nnoremap <silent> <C-]> :FufTag! <C-r>=expand('<cword>')<CR><CR> 

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


" flex
augroup Fcsh
	au!
"	autocmd BufWritePost *.{as,mxml} call FcshCall()
augroup END

function! FcshCall()
	let ret = system('ruby -rdrb/drb -e "puts DRbObject.new_with_uri(''druby://localhost:8787'').call(ARGV[0])"  "'.expand("%:p").'"')
	if matchstr(ret, 'Error') != ""
		echo ret
	endif
endfunction


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
      \   'java' : [
      \     {
      \       'command'  : "\<C-n>",
      \       'pattern'  : '\k\k$',
      \       'excluded' : '^$',
      \       'repeat'   : 0,
      \     },
      \     {
      \       'command'  : "\<C-x>\<C-u>",
      \       'pattern'  : '\k\k$',
      \       'excluded' : '^$',
      \       'repeat'   : 0,
      \     },
      \     {
      \       'command'  : "\<C-x>\<C-f>",
      \       'pattern'  : (has('win32') || has('win64') ? '\f[/\\]\f*$' : '\f[/]\f*$'),
      \       'excluded' : '[*/\\][/\\]\f*$\|[^[:print:]]\f*$',
      \       'repeat'   : 1,
      \     }
      \   ]
      \ }

autocmd BufNewFile,BufRead *.io set filetype=io
autocmd BufNewFile,BufRead *.scala set filetype=scala
autocmd BufNewFile,BufRead COMMIT_EDITMSG set filetype=git fenc=utf-8

autocmd BufNewFile,BufRead */Hatena*/*.{html,tt} set ft=html | setlocal softtabstop=2 tabstop=2 shiftwidth=2
autocmd BufNewFile,BufRead */Hatena* setlocal expandtab

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

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


command! -bang -narg=0  HatenaStamp call append(line('.'), "*" . localtime() . "*") | execute "normal jo"


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
	let repos = substitute(git_output, 'git@192.168.2.181:/var/git', '', '')
	let commit = substitute(system('git name-rev --name-only HEAD'), '\n*$', '', '')

	let repos = substitute(repos, '\(.git\)*$', '.git', '')

	call system('open http://repository01.host.h:5001/gitweb.cgi' . repos . '/blob/' . commit . ':' . expand('%') . '#l' . line('.'))
endfunction
command! GitWeb call GitWeb()

