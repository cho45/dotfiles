" LOAD GUARD {{{1

if !l9#guardScriptLoading(expand('<sfile>:p'), 0, 0, [])
  finish
endif


" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#script#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#script#getSwitchOrder()
  return -1
endfunction

"
function fuf#script#getEditableDataNames()
  return []
endfunction

"
function fuf#script#renewCache()
  let s:cache = {}
endfunction

"
function fuf#script#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#script#onInit()
endfunction

"
function fuf#script#launch(initialPattern, partialMatching, prompt, runner, script, cache)
  let s:prompt = (empty(a:prompt) ? '>' : a:prompt)

  let key = join([a:runner, a:script], "\n")
  if exists('s:cache[key]')
    let s:items = s:cache[key]
  else
    let s:items = split(system(printf("%s %s %s", a:runner, a:script, expand('%'))), "\n")
    call map(s:items, 's:makeItem(v:val)')
    call fuf#mapToSetSerialIndex(s:items, 1)
    call map(s:items, 'fuf#setAbbrWithFormattedWord(v:val, 1)')
    if a:cache
      let s:cache[key] = s:items
    end
  endif

  call fuf#launch(s:MODE_NAME, a:initialPattern, a:partialMatching)
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

"
function s:makeItem(line)
  let line = split(a:line, "\t")
  let item = fuf#makeNonPathItem(line[0], "")
  let item.command = line[1]
  return item
endfunction

" }}}1
"=============================================================================
" s:handler {{{1

let s:handler = {}

"
function s:handler.getModeName()
  return s:MODE_NAME
endfunction

"
function s:handler.getPrompt()
  return fuf#formatPrompt(s:prompt, self.partialMatching, '')
endfunction

"
function s:handler.getPreviewHeight()
  return 0
endfunction

"
function s:handler.isOpenable(enteredPattern)
  return 1
endfunction

"
function s:handler.makePatternSet(patternBase)
  return fuf#makePatternSet(a:patternBase, 's:interpretPrimaryPatternForNonPath',
        \                   self.partialMatching)
endfunction

"
function s:handler.makePreviewLines(word, count)
  return []
endfunction

"
function s:handler.getCompleteItems(patternPrimary)
  return s:items
endfunction

"
function s:handler.onOpen(word, mode)
  let result = filter(copy(s:items), 'v:val.word == a:word')[0]
  echo result.command
  execute result.command
endfunction

"
function s:handler.onModeEnterPre()
endfunction

"
function s:handler.onModeEnterPost()
endfunction

"
function s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:

call fuf#addMode('script')
