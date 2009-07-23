
syn keyword ioCommentTodo      TODO FIXME XXX TBD contained
syn match   ioCommentSkip      "^[ \t]*\*\($\|[ \t]\+\)"
syn match   ioLineComment      "\/\/.*\|#.*" contains=@Spell,ioCommentTodo
syn region  ioComment          start="/\*"  end="\*/" contains=@Spell,ioCommentTodo
syn region  ioStringD          start=+"+  skip=+\\\\\|\\"+  end=+"\|$+
syn region  ioStringT          start=+"""+  end=+"""+  contains=ioSpecial,@htmlPreproc

syn match   ioObject           "\<[A-Z]\w\+\>"
syn match   ioStatementM       "@\|?"

syn keyword ioConditional      if
syn keyword ioRepeat           loop while for repeat
syn keyword ioBranch           break continue return
syn keyword ioCore             Addon AddonLoader Block CFunction CLI Call Collector Compiler Coroutine Date Debugger Directory Duration DynLib Exception File Future ImmutableSequence Importer List Map Message Notifier Number Object Path Range Sandbox Scheduler Sequence SerializationStream Store String System TestSuite UnitTest WeakLink 
syn keyword ioBoolean          true false
syn keyword ioNil              nil
syn keyword ioException        try catch pass
syn keyword ioGlobal           Lobby
syn keyword ioDynBinding       self proto
syn keyword ioBlock            block method
syn keyword ioGlobalMethod     list
syn keyword ioStatement        do exit yield wait super resend pause



syn sync fromstart
syn sync maxlines=100

syn sync ccomment ioComment

hi def link ioComment           Comment
hi def link ioLineComment       Comment
hi def link ioCommentTodo       Todo
hi def link ioSpecial           Special
hi def link ioStringD           String
hi def link ioStringT           String
hi def link ioRepeat            Repeat
hi def link ioConditional       Conditional
hi def link ioBranch            Conditional
hi def link ioCore              Type
hi def link ioBlock             Function
hi def link ioError             Error
hi def link ioNil               Keyword
hi def link ioBoolean           Boolean
hi def link ioStatement         Statement
hi def link ioStatementM        Statement
hi def link ioDynBinding        Statement
hi def link ioObject            Type

hi def link ioException         Exception
hi def link ioGlobal            Keyword
hi def link ioGlobalMethod      Keyword

let b:current_syntax = "io"

" vim: ts=8
