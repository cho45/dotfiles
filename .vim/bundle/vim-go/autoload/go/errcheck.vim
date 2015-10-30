if !exists("g:go_errcheck_bin")
    let g:go_errcheck_bin = "errcheck"
endif

function! go#errcheck#Run(...) abort
    if a:0 == 0
        let goargs = go#package#ImportPath(expand('%:p:h'))
        if goargs == -1
            echohl Error | echomsg "vim-go: package is not inside GOPATH src" | echohl None
            return
        endif
    else
        let goargs = go#util#Shelljoin(a:000)
    endif

    let bin_path = go#path#CheckBinPath(g:go_errcheck_bin)
    if empty(bin_path)
        return
    endif

    echon "vim-go: " | echohl Identifier | echon "errcheck analysing ..." | echohl None
    redraw

    let command = bin_path . ' ' . goargs
    let out = go#tool#ExecuteInDir(command)

    if v:shell_error
        let errors = []
        let mx = '^\(.\{-}\):\(\d\+\):\(\d\+\)\s*\(.*\)'
        for line in split(out, '\n')
            let tokens = matchlist(line, mx)
            if !empty(tokens)
                call add(errors, {"filename": expand(go#path#Default() . "/src/" . tokens[1]),
                            \"lnum": tokens[2],
                            \"col": tokens[3],
                            \"text": tokens[4]})
            endif
        endfor

        if empty(errors)
            echohl Error | echomsg "GoErrCheck returned error" | echohl None
            echo out
        endif

        if !empty(errors)
            redraw | echo
            call setqflist(errors, 'r')
        endif
    else
        redraw | echo
        call setqflist([])
        echon "vim-go: " | echohl Function | echon "[errcheck] PASS" | echohl None
    endif

    cwindow
endfunction

" vim:ts=4:sw=4:et
