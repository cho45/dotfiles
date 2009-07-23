" surround.vim - Surroundings
" Author:       Tim Pope <vimNOSPAM@tpope.info>
" GetLatestVimScripts: 1697 1 :AutoInstall: surround.vim
" $Id: surround.vim,v 1.19 2006/11/14 07:16:55 tpope Exp $
"
" See surround.txt for help.  This can be accessed by doing
"
" :helptags ~/.vim/doc
" :help surround
"
" Licensed under the same terms as Vim itself.

" ============================================================================

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if (exists("g:loaded_surround") && g:loaded_surround) || &cp
    finish
endif
let g:loaded_surround = 1

let s:cpo_save = &cpo
set cpo&vim

" Input functions {{{1

function! s:getchar()
    let c = getchar()
    if c =~ '^\d\+$'
        let c = nr2char(c)
    endif
    return c
endfunction

function! s:inputtarget()
    let c = s:getchar()
    while c =~ '^\d\+$'
        let c = c . s:getchar()
    endwhile
    if c == " "
        let c = c . s:getchar()
    endif
    if c =~ "\<Esc>\|\<C-C>\|\0"
        return ""
    else
        return c
    endif
endfunction

function! s:inputreplacement()
    "echo '-- SURROUND --'
    let c = s:getchar()
    if c == " "
        let c = c . s:getchar()
    endif
    if c =~ "\<Esc>" || c =~ "\<C-C>"
        return ""
    else
        return c
    endif
endfunction

function! s:beep()
    exe "norm! \<Esc>"
    return ""
endfunction

function! s:redraw()
    redraw
    return ""
endfunction

" }}}1

" Wrapping functions {{{1

function! s:extractbefore(str)
    if a:str =~ '\r'
        return matchstr(a:str,'.*\ze\r')
    else
        return matchstr(a:str,'.*\ze\n')
    endif
endfunction

function! s:extractafter(str)
    if a:str =~ '\r'
        return matchstr(a:str,'\r\zs.*')
    else
        return matchstr(a:str,'\n\zs.*')
    endif
endfunction

function! s:repeat(str,count)
    let cnt = a:count
    let str = ""
    while cnt > 0
        let str = str . a:str
        let cnt = cnt - 1
    endwhile
    return str
endfunction

function! s:fixindent(str,spc)
    let str = substitute(a:str,'\t',s:repeat(' ',&sw),'g')
    let spc = substitute(a:spc,'\t',s:repeat(' ',&sw),'g')
    let str = substitute(str,'\(\n\|\%^\).\@=','\1'.spc,'g')
    if ! &et
        let str = substitute(str,'\s\{'.&ts.'\}',"\t",'g')
    endif
    return str
endfunction

function! s:wrap(string,char,type,...)
    let keeper = a:string
    let newchar = a:char
    let type = a:type
    let linemode = type ==# 'V' ? 1 : 0
    let special = a:0 ? a:1 : 0
    let before = ""
    let after  = ""
    if type == "V"
        let initspaces = matchstr(keeper,'\%^\s*')
    else
        let initspaces = matchstr(getline('.'),'\%^\s*')
    endif
    " Duplicate b's are just placeholders (removed)
    let pairs = "b()B{}r[]a<>"
    let extraspace = ""
    if newchar =~ '^ '
        let newchar = strpart(newchar,1)
        let extraspace = ' '
    endif
    let idx = stridx(pairs,newchar)
    if exists("b:surround_".char2nr(newchar))
        let before = s:extractbefore(b:surround_{char2nr(newchar)})
        let after  =  s:extractafter(b:surround_{char2nr(newchar)})
    elseif exists("g:surround_".char2nr(newchar))
        let before = s:extractbefore(g:surround_{char2nr(newchar)})
        let after  =  s:extractafter(g:surround_{char2nr(newchar)})
    elseif newchar ==# "p"
        let before = "\n"
        let after  = "\n\n"
    elseif newchar =~# "[tT\<C-T><,]"
        "let dounmapr = 0
        let dounmapb = 0
        "if !mapcheck("<CR>","c")
            "let dounmapr = 1
            "cnoremap <CR> ><CR>
        "endif
        if !mapcheck(">","c")
            let dounmapb= 1
            cnoremap > ><CR>
        endif
        let default = ""
        if newchar ==# "T"
            if !exists("s:lastdel")
                let s:lastdel = ""
            endif
            let default = matchstr(s:lastdel,'<\zs.\{-\}\ze>')
        endif
        let tag = input("<",default)
        echo "<".substitute(tag,'>*$','>','')
        "if dounmapr
            "silent! cunmap <CR>
        "endif
        if dounmapb
            silent! cunmap >
        endif
        if tag != ""
            let tag = substitute(tag,'>*$','','')
            let before = "<".tag.">"
            let after  = "</".substitute(tag," .*",'','').">"
            if newchar == "\<C-T>" || newchar == ","
                if type ==# "v" || type ==# "V"
                    let before = before . "\n\t"
                endif
                if type ==# "v"
                    let after  = "\n". after
                endif
            endif
        endif
    elseif newchar ==# 'l' || newchar == '\'
        " LaTeX
        let env = input('\begin{')
        let env = '{' . env
        let env = env . s:closematch(env)
        echo '\begin'.env
        if env != ""
            let before = '\begin'.env
            let after  = '\end'.matchstr(env,'[^}]*').'}'
        endif
        "if type ==# 'v' || type ==# 'V'
            "let before = before ."\n\t"
        "endif
        "if type ==# 'v'
            "let after  = "\n".initspaces.after
        "endif
    elseif newchar ==# 'f' || newchar ==# 'F'
        let fnc = input('function: ')
        if fnc != ""
            let before = substitute(fnc,'($','','').'('
            let after  = ')'
            if newchar ==# 'F'
                let before = before . ' '
                let after  = ' ' . after
            endif
        endif
    elseif idx >= 0
        let spc = (idx % 3) == 1 ? " " : ""
        let idx = idx / 3 * 3
        let before = strpart(pairs,idx+1,1) . spc
        let after  = spc . strpart(pairs,idx+2,1)
    elseif newchar !~ '\a'
        let before = newchar
        let after  = newchar
    else
        let before = ''
        let after  = ''
    endif
    "let before = substitute(before,'\n','\n'.initspaces,'g')
    let after  = substitute(after ,'\n','\n'.initspaces,'g')
    "let after  = substitute(after,"\n\\s*\<C-U>\\s*",'\n','g')
    if type ==# 'V' || (special && type ==# "v")
        let before = substitute(before,' \+$','','')
        let after  = substitute(after ,'^ \+','','')
        if after !~ '^\n'
            let after  = initspaces.after
        endif
        if keeper !~ '\n$' && after !~ '^\n'
            let keeper = keeper . "\n"
        endif
        if before !~ '\n\s*$'
            let before = before . "\n"
            if special
                let before = before . "\t"
            endif
        endif
    endif
    if type ==# 'V'
        let before = initspaces.before
    endif
    if before =~ '\n\s*\%$'
        if type ==# 'v'
            let keeper = initspaces.keeper
        endif
        let padding = matchstr(before,'\n\zs\s\+\%$')
        let before  = substitute(before,'\n\s\+\%$','\n','')
        let keeper = s:fixindent(keeper,padding)
    endif
    if type ==# 'V'
        let keeper = before.keeper.after
    elseif type =~ "^\<C-V>"
        " Really we should be iterating over the buffer
        let repl = substitute(before,'[\\~]','\\&','g').'\1'.substitute(after,'[\\~]','\\&','g')
        let repl = substitute(repl,'\n',' ','g')
        let keeper = substitute(keeper."\n",'\(.\{-\}\)\('.(special ? '\s\{-\}' : '').'\n\)',repl.'\n','g')
        let keeper = substitute(keeper,'\n\%$','','')
    else
        let keeper = before.extraspace.keeper.extraspace.after
    endif
    return keeper
endfunction

function! s:wrapreg(reg,char,...)
    let orig = getreg(a:reg)
    let type = substitute(getregtype(a:reg),'\d\+$','','')
    let special = a:0 ? a:1 : 0
    let new = s:wrap(orig,a:char,type,special)
    call setreg(a:reg,new,type)
endfunction
" }}}1

function! s:insert(...) " {{{1
    " Optional argument causes the result to appear on 3 lines, not 1
    "call inputsave()
    let linemode = a:0 ? a:1 : 0
    let char = s:inputreplacement()
    while char == "\<CR>" || char == "\<C-S>"
        " TODO: use total count for additional blank lines
        let linemode = linemode + 1
        let char = s:inputreplacement()
    endwhile
    "call inputrestore()
    if char == ""
        return ""
    endif
    "call inputsave()
    let reg_save = @@
    call setreg('"',"\r",'v')
    call s:wrapreg('"',char,linemode)
    "if linemode
        "call setreg('"',substitute(getreg('"'),'^\s\+','',''),'c')
    "endif
    if col('.') > col('$')
        norm! p`]
    else
        norm! P`]
    endif
    call search('\r','bW')
    let @@ = reg_save
    return "\<Del>"
endfunction " }}}1

function! s:reindent() " {{{1
    if (exists("b:surround_indent") || exists("g:surround_indent"))
        silent norm! '[=']
    endif
endfunction " }}}1

function! s:dosurround(...) " {{{1
    let scount = v:count1
    let char = (a:0 ? a:1 : s:inputtarget())
    let spc = ""
    if char =~ '^\d\+'
        let scount = scount * matchstr(char,'^\d\+')
        let char = substitute(char,'^\d\+','','')
    endif
    if char =~ '^ '
        let char = strpart(char,1)
        let spc = 1
    endif
    if char == 'a'
        let char = '>'
    endif
    if char == 'r'
        let char = ']'
    endif
    let newchar = ""
    if a:0 > 1
        let newchar = a:2
        if newchar == "\<Esc>" || newchar == "\<C-C>" || newchar == ""
            return s:beep()
        endif
    endif
    let append = ""
    let original = getreg('"')
    let otype = getregtype('"')
    call setreg('"',"")
    exe "norm d".(scount==1 ? "": scount)."i".char
    "exe "norm vi".char."d"
    let keeper = getreg('"')
    let okeeper = keeper " for reindent below
    if keeper == ""
        call setreg('"',original,otype)
        return ""
    endif
    let oldline = getline('.')
    let oldlnum = line('.')
    if char ==# "p"
        "let append = matchstr(keeper,'\n*\%$')
        "let keeper = substitute(keeper,'\n*\%$','','')
        call setreg('"','','V')
    elseif char ==# "s" || char ==# "w" || char ==# "W"
        " Do nothing
        call setreg('"','')
    elseif char =~ "[\"'`]"
        exe "norm! i \<Esc>d2i".char
        call setreg('"',substitute(getreg('"'),' ','',''))
    else
        exe "norm! da".char
    endif
    let removed = getreg('"')
    let rem2 = substitute(removed,'\n.*','','')
    let oldhead = strpart(oldline,0,strlen(oldline)-strlen(rem2))
    let oldtail = strpart(oldline,  strlen(oldline)-strlen(rem2))
    let regtype = getregtype('"')
    if char == 'p'
        let regtype = "V"
    endif
    if char =~# '[\[({<T]' || spc
        let keeper = substitute(keeper,'^\s\+','','')
        let keeper = substitute(keeper,'\s\+$','','')
    endif
    if col("']") == col("$") && col('.') + 1 == col('$')
        "let keeper = substitute(keeper,'^\n\s*','','')
        "let keeper = substitute(keeper,'\n\s*$','','')
        if oldhead =~# '^\s*$' && a:0 < 2
            "let keeper = substitute(keeper,oldhead.'\%$','','')
            let keeper = substitute(keeper,'\%^\n'.oldhead.'\(\s*.\{-\}\)\n\s*\%$','\1','')
        endif
        let pcmd = "p"
    else
        if oldhead == "" && a:0 < 2
            "let keeper = substitute(keeper,'\%^\n\(.*\)\n\%$','\1','')
        endif
        let pcmd = "P"
    endif
    if line('.') < oldlnum && regtype ==# "V"
        let pcmd = "p"
    endif
    call setreg('"',keeper,regtype)
    if newchar != ""
        call s:wrapreg('"',newchar)
    endif
    silent exe "norm! ".pcmd.'`['
    if removed =~ '\n' || okeeper =~ '\n' || getreg('"') =~ '\n'
        call s:reindent()
    else
    endif
    if getline('.') =~ '^\s\+$' && keeper =~ '^\s*\n'
        silent norm! cc
    endif
    call setreg('"',removed,regtype)
    let s:lastdel = removed
endfunction " }}}1

function! s:changesurround() " {{{1
    let a = s:inputtarget()
    if a == ""
        return s:beep()
    endif
    let b = s:inputreplacement()
    if b == ""
        return s:beep()
    endif
    call s:dosurround(a,b)
endfunction " }}}1

function! s:opfunc(type,...) " {{{1
    let char = s:inputreplacement()
    if char == ""
        return s:beep()
    endif
    let reg = '"'
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = getreg(reg)
    let reg_type = getregtype(reg)
    let type = a:type
    if a:type == "char"
        silent exe 'norm! v`[o`]"'.reg."y"
        let type = 'v'
    elseif a:type == "line"
        silent exe 'norm! `[V`]"'.reg."y"
        let type = 'V'
    elseif a:type ==# "v" || a:type ==# "V" || a:type ==# "\<C-V>"
        silent exe 'norm! gv"'.reg."y"
    elseif a:type =~ '^\d\+$'
        silent exe 'norm! ^v'.a:type.'$h"'.reg.'y'
    else
        let &selection = sel_save
        return s:beep()
    endif
    let keeper = getreg(reg)
    if type == "v" && a:type != "v"
        let append = matchstr(keeper,'\_s\@<!\s*$')
        let keeper = substitute(keeper,'\_s\@<!\s*$','','')
    endif
    call setreg(reg,keeper,type)
    call s:wrapreg(reg,char,a:0)
    if type == "v" && a:type != "v" && append != ""
        call setreg(reg,append,"ac")
    endif
    silent exe 'norm! gv'.(reg == '"' ? '' : '"' . reg).'p`['
    if type == 'V' || (getreg(reg) =~ '\n' && type == 'v')
        call s:reindent()
    endif
    call setreg(reg,reg_save,reg_type)
    let &selection = sel_save
endfunction

function! s:opfunc2(arg)
    call s:opfunc(a:arg,1)
endfunction " }}}1

function! s:closematch(str) " {{{1
    " Close an open (, {, [, or < on the command line.
    let tail = matchstr(a:str,'.[^\[\](){}<>]*$')
    if tail =~ '^\[.\+'
        return "]"
    elseif tail =~ '^(.\+'
        return ")"
    elseif tail =~ '^{.\+'
        return "}"
    elseif tail =~ '^<.+'
        return ">"
    else
        return ""
    endif
endfunction " }}}1

nnoremap <silent> <Plug>Dsurround  :<C-U>call <SID>dosurround(<SID>inputtarget())<CR>
nnoremap <silent> <Plug>Csurround  :<C-U>call <SID>changesurround()<CR>
nnoremap <silent> <Plug>Yssurround :<C-U>call <SID>opfunc(v:count1)<CR>
nnoremap <silent> <Plug>YSsurround :<C-U>call <SID>opfunc2(v:count1)<CR>
" <C-U> discards the numerical argument but there's not much we can do with it
nnoremap <silent> <Plug>Ysurround  :<C-U>set opfunc=<SID>opfunc<CR>g@
nnoremap <silent> <Plug>YSurround  :<C-U>set opfunc=<SID>opfunc2<CR>g@
vnoremap <silent> <Plug>Vsurround  :<C-U>call <SID>opfunc(visualmode())<CR>
vnoremap <silent> <Plug>VSurround  :<C-U>call <SID>opfunc2(visualmode())<CR>
inoremap <silent> <Plug>Isurround  <C-R>=<SID>insert()<CR>
inoremap <silent> <Plug>ISurround  <C-R>=<SID>insert(1)<CR>

if !exists("g:surround_no_mappings") || ! g:surround_no_mappings
    nmap          ds   <Plug>Dsurround
    nmap          cs   <Plug>Csurround
    nmap          ys   <Plug>Ysurround
    nmap          yS   <Plug>YSurround
    nmap          yss  <Plug>Yssurround
    nmap          ySs  <Plug>YSsurround
    nmap          ySS  <Plug>YSsurround
    if !hasmapto("<Plug>Vsurround","v")
        vmap      s    <Plug>Vsurround
    endif
    if !hasmapto("<Plug>VSurround","v")
        vmap      S    <Plug>VSurround
    endif
    if !hasmapto("<Plug>Isurround","i") && !mapcheck("<C-S>","i")
        imap     <C-S> <Plug>Isurround
    endif
    imap        <C-G>s <Plug>Isurround
    imap        <C-G>S <Plug>ISurround
    "Implemented internally instead
    "imap     <C-S><C-S> <Plug>ISurround
endif

let &cpo = s:cpo_save

" vim:set ft=vim sw=4 sts=4 et:
