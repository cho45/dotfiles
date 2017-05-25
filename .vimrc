" For :PlugInstall / :PlugUpdate
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

" --------------------------------------------------------------------------------
" Setup Plug {
	filetype off
	call plug#begin('~/.vim/plugged')
		Plug 'vim-scripts/L9'
		Plug 'cho45/vim-fuzzyfinder'
		Plug 'kana/vim-metarw'

		" tsuquyomi dependency
		Plug 'Shougo/vimproc.vim', { 'do': 'make' }

		Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
		Plug 'Quramy/tsuquyomi', { 'for': 'typescript' }

		Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }

		Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
"		Plug 'mattn/jscomplete-vim', { 'for': 'javascript' }
		Plug 'myhere/vim-nodejs-complete', { 'for': 'javascript' }

		Plug 'fatih/vim-go', { 'for': 'go' }
	call plug#end()
" }


" --------------------------------------------------------------------------------
" Load .vim/bundle/* {
	call pathogen#runtime_append_all_bundles()
" }


" --------------------------------------------------------------------------------
" Basic Settings {
	syntax on
	filetype plugin on
	filetype indent on

	set listchars=tab:>.,precedes:<,extends:>
	set list
	set textwidth=1000
	set directory=~/swp

	set wildmode=longest,list
	set ambiwidth=double
	set completeopt=menu,preview,longest,menuone
	set complete=.,w,b,u,k
	set nobackup
	set autoread
	set scrolloff=10000000
	set number
	set autoindent smartindent
	set smarttab
	set softtabstop=4 tabstop=4 shiftwidth=4
	set backspace=indent,eol,start
	set ignorecase smartcase
	set incsearch
	set wrapscan
	set showmatch
	set showcmd
	set whichwrap=b,s,h,l,<,>,[,]
	set wildmenu
	set splitbelow
	set nrformats="hex"
	set undofile
	set undodir=~/swp

	set termencoding=utf-8
	set encoding=utf-8
	set fileencodings=utf-8,euc-jp,iso-2022-jp,cp932
	set hidden
	set viminfo+=!
	set nowrap
	set sidescroll=5
	set iminsert=0
	set imsearch=0
	set nofoldenable
	set lazyredraw

	set laststatus=2
	set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']['.&ft.']'}\ %=\ %l,%c%V%8P
" }
"

" --------------------------------------------------------------------------------
" Color Settings {
	if &term =~ "xterm-256color"
		colorscheme desert256mod
	endif

	" ポップアップ補完メニュー色設定（通常の項目、選択されている項目、スクロールバー、スクロールバーのつまみ部分）
	" Pmenu は bg/fg が逆
	highlight Pmenu      ctermfg=8 ctermbg=15
	highlight PmenuSel   ctermbg=0 ctermfg=6
	highlight PmenuSbar  ctermbg=1 ctermfg=2
	highlight PmenuThumb ctermbg=0 ctermfg=2

	highlight ZenkakuSpace ctermbg=6
	match ZenkakuSpace /\s\+$\|　/
" }


" --------------------------------------------------------------------------------
" mappings {
	inoremap  <BS>
	nnoremap Y y$

	nnoremap j gj
	nnoremap k gk

	inoremap <expr> <CR> pumvisible() ? "\<C-Y>\<CR>" : "\<CR>"

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

	" redraw map
	nnoremap <silent> sr :redraw!<CR>

	" swap conditional operator
	nnoremap e3 :s/?\s*\((.\{-1,})\\|\S\+\)\s*:\s*\((.\{-1,})\\|\S\+\)/? \2 : \1/<CR>


	" insert timestamp
	nnoremap tw :exe "normal! i" . strftime("%Y-%m-%d\T%H:%M:%S+09:00")<CR>

	" auto resize window
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

	" Fix typo
	iabbr slef self
	iabbr sefl self
	iabbr tihs this
	iabbr thsi this
	iabbr crete create
	iabbr funciton function
" }

" --------------------------------------------------------------------------------
" yanktemp {
	noremap <silent> sy :call YanktmpYank()<CR>
	noremap <silent> sp :call YanktmpPaste_p()<CR>
	noremap <silent> sP :call YanktmpPaste_P()<CR>
" }


" --------------------------------------------------------------------------------
" jptemplate {
	let g:jpTemplateKey        = '<C-B>'
" }


" --------------------------------------------------------------------------------
" pasteboard support {
	noremap <silent> sY :call YankPB()<CR>
	function! YankPB() range
		let @* = join(getline(a:firstline, a:lastline), "\n")
	endfunction
" }


" --------------------------------------------------------------------------------
" git history {
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
" }


" --------------------------------------------------------------------------------
" ShebangExecute {
	nnoremap ,e :call ShebangExecute()<CR>
	function! ShebangExecute()
		let m = matchlist(getline(1), '#!\(.*\)')
		if(len(m) > 2)
			execute '!'. m[1] . ' %'
		else
			execute '!' &ft ' %'
		endif
	endfunction
" }


" --------------------------------------------------------------------------------
" FuzzyFinder {
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
" }


" --------------------------------------------------------------------------------
" AutoComplePop {
	let g:acp_completeOption = '.,w,b,k'
	let g:acp_behavior = {
		  \   'javascript' : [
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
" }


" --------------------------------------------------------------------------------
" Generic autocmd {
	" set screen window name
	autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | silent! exe '!echo -n "k%\\"' | endif

	" auto chmod +x to #!
	autocmd BufWritePost * if getline(1) =~ "^#!" | exe "silent !chmod +x %" | endif

	" Hatena:::Let
	autocmd BufWritePost */debuglet.js silent! execute '!ruby ' . $HOME . '/bin/debuglet.rb %'
	autocmd BufNewFile */debuglet.js silent! execute 'r!ruby ' . $HOME . '/bin/debuglet.rb'
" }


" --------------------------------------------------------------------------------
" Auto mkdir {
	augroup AutoMkdir
		function! s:auto_mkdir(dir, force)
			if !isdirectory(a:dir) && (a:force || input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
				call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
			endif
		endfunction

		autocmd!
		autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
	augroup END
" }


" --------------------------------------------------------------------------------
" go-lang {
	let $GOROOT = substitute(system("go env GOROOT"), "\n", "", "g")
	if $GOROOT != ''
		set runtimepath+=$GOROOT/misc/vim
		exe "set runtimepath+=".globpath($GOPATH, "src/github.com/nsf/gocode/vim")
	endif

	autocmd BufNewFile,BufRead *.go set filetype=go
	autocmd FileType go setlocal sw=4 ts=4 sts=4 noet
	autocmd FileType go setlocal makeprg=go\ build\ ./... errorformat=%f:%l:\ %m
" }


" --------------------------------------------------------------------------------
" Perl {
	let g:Perl_AuthorName      = 'cho45'
	let g:Perl_AuthorRef       = ''
	let g:Perl_Email           = 'cho45@lowreal.net'
	let g:Perl_Company         = ''

	autocmd BufNewFile,BufRead *.t set filetype=perl
	autocmd BufNewFile,BufRead *.psgi set filetype=perl
" }


" --------------------------------------------------------------------------------
" netrw {
	let g:netrw_preview        = 1
" }


" --------------------------------------------------------------------------------
" html {
	let g:use_xhtml = 1
	let g:html_use_css = 1
	let g:html_number_lines = 0

	autocmd BufNewFile,BufRead *.tt set filetype=html
	autocmd BufNewFile,BufRead *.tx set filetype=html
	autocmd BufNewFile,BufRead *.html set filetype=html
" }


" --------------------------------------------------------------------------------
" css {
	autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
" }


" --------------------------------------------------------------------------------
" javascript {
"	autocmd FileType javascript setlocal omnifunc=jscomplete#CompleteJS
" }


" --------------------------------------------------------------------------------
" ruby {
	autocmd FileType ruby setlocal sw=4 ts=4 sts=4
" }


" --------------------------------------------------------------------------------
" yaml {
	autocmd FileType yaml setlocal expandtab ts=2 sw=2 enc=utf-8 fenc=utf-8
" }


" --------------------------------------------------------------------------------
" scala {
	autocmd BufNewFile,BufRead *.scala set filetype=scala
" }


" --------------------------------------------------------------------------------
" io {
	autocmd BufNewFile,BufRead *.io set filetype=io
" }
"


" --------------------------------------------------------------------------------
" git {
	autocmd BufNewFile,BufRead COMMIT_EDITMSG set filetype=git fenc=utf-8
	command! -nargs=* -range GitBrowseRemote !git browse-remote --rev -L<line1>,<line2> <f-args> -- %
" }


" --------------------------------------------------------------------------------
" ChangeLog {
	let g:changelog_timeformat = "%Y-%m-%d"
	let g:changelog_username   = "SATOH Hiroh <cho45@lowreal.net>"
	let g:changelog_date_end_entry_search = '^\s*$'
" }

