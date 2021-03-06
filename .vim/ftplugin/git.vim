" Vim syntax file
" Language:	git commit message

" Quit when a (custom) syntax file was already loaded
"if exists("b:current_syntax")
"  finish
"endif

syn region gitSignedOff start=/^Signed-off-by:/ end=/$/ contains=gitAuthor,gitEmail
syn region gitAuthor contained start=/\s/ end=/$/

syn region gitLine start=/^#/ end=/$/
syn region gitCommit start=/^# Changes to be committed:$/ end=/^#$/ contains=gitHead,gitCommitFile
syn region gitHead contained start=/^#   (.*)/ end=/^#$/
syn region gitChanged start=/^# Changed but not updated:/ end=/^#$/ contains=gitHead,gitChangedFile
syn region gitUntracked start=/^# Untracked files:/ end=/^#$/ contains=gitHead,gitUntrackedFile

syn match gitCommitFile contained /^#\t.*/hs=s+2
syn match gitChangedFile contained /^#\t.*/hs=s+2
syn match gitUntrackedFile contained /^#\t.*/hs=s+2

hi def link gitSignedOff Keyword
hi def link gitAuthor Normal

hi def link gitLine Comment
hi def link gitCommit Comment
hi def link gitChanged Comment
hi def link gitHead Comment
hi def link gitUntracked Comment
hi def link gitCommitFile Type
hi def link gitChangedFile Constant
hi def link gitUntrackedFile Constant

let b:current_syntax = "git"

" vim: ts=8 sw=2
