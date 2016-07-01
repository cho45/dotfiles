" jptemplate.vim:
"
" A simple yet powerful interactive templating system for VIM.
"
" Version 1.5 (released 2008-07-08).
"
" Copyright (c) 2008 Jannis Pohlmann <jannis@xfce.org>.
"
" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation; either version 2 of the License, or (at
" your option) any later version.
"
" This program is distributed in the hope that it will be useful, but
" WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
" General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program; if not, write to the Free Software
" Foundation, Inc., 59 Temple Place, Suite 330, Boston,
" MA  02111-1307  USA


" Reserved variable names
let s:reservedVariables = ['date','shell','interactive_shell', 'execute', 'call']

" Variable value history
let s:rememberedValues = {}

" Characters to be escaped before the substitute() call
let s:escapeCharacters = '&~\'


function! s:Initialize ()

  " List for default configuration
  let defaults = []

  " Default configuration values
  call add (defaults, ['g:jpTemplateDir', $HOME . '/.vim/jptemplate'])
  call add (defaults, ['g:jpTemplateKey', '<C-Tab>'])
  call add (defaults, ['g:jpTemplateDateFormat', '%Y-%m-%d'])
  call add (defaults, ['g:jpTemplateDefaults', {}])
  call add (defaults, ['g:jpTemplateVerbose', 0])

  " Set default configuration for non-existent variables
  for var in filter (defaults, '!exists (v:val[0])')
    exec 'let ' . var[0] . ' = ' . string (var[1])
  endfor

endfunction


function! s:GetTemplateInfo ()

  " Prepare info dictionary
  let info = {}

  " Get part of the line before the cursor
  let part = getline  ('.')[0 : getpos ('.')[2]-1]

  " Get start and end position of the template name
  let info['start'] = match    (part, '\(\w*\)$')
  let info['end']   = matchend (part, '\(\w*\)$')

  " Get template name
  let info['name']  = part[info['start'] : info['end']]

  " Throw exception if no template name could be found
  if empty (info['name'])
    throw 'No template name found at cursor'
  endif

  " Determine directory to load the template from (skip empty directories;
  " each directory may override the ones before)
  for dir in filter ([ 'general', &ft ], '!empty (v:val)')
    let filename = g:jpTemplateDir .'/'. dir .'/'. info['name']
    if filereadable (filename)
      let info['filename'] = filename
    endif
  endfor

  " Throw exception if the template file does not exist in any of these
  " directories (or is not readable)
  if !has_key (info, 'filename')
    throw 'Template file not found'
  endif

  " Determine indentation
  let info['indent'] = matchstr (part, '^\s\+')

  " Return template name information
  return info

endfunction


function! s:ReadTemplate (name, filename)

  " Try to read the template file and throw exception if that fails
  try
    return readfile (a:filename)
  catch
    throw 'Template "' . a:name . '" could not be found.'
  endtry

endfunction


function! s:UpdateCursorPosition (lines, endColumn)

  " Define cursorPosition as the column to which the cursor is moved
  let cursorPosition = -1

  for cnt in range (0, a:lines)
    " Search for ${cursor} in the current line
    let str    = getline  (line ('.') + cnt)
    let start  = match    (str, '${cursor}')
    let end    = matchend (str, '${cursor}')
    let before = strpart  (str, 0, start)
    let after  = strpart  (str, end)

    if start >= 0
      " Remove ${cursor} and move the cursor to the desired position
      call setline (line ('.') + cnt, before . after)
      call cursor (line ('.') + cnt, start+1)

      let cursorPosition = start

      " We're done
      break
    endif
  endfor

  " Update cursor position in case no ${cursor} was found in the template
  " and the resulting template was not empty
  if cursorPosition == -1 && a:lines >= 0
    if a:lines == 0
      call cursor (line ('.'), a:endColumn + 1)
    else
      call cursor (line ('.') + a:lines, a:endColumn + 1)
    endif
  endif

  " Return to insert mode (distinguish between 'in the middle of the line' and
  " 'at the end of the line')
  if col ('.') == len (getline ('.')) 
    startinsert!
  else
    startinsert
  endif

endfunction


function! s:ParseExpression (expr)

  " Determine position of the separator between name and value
  let valuepos = match (a:expr, ':')

  " Extract name and value strings
  let name  = valuepos >= 0 ? strpart (a:expr, 0, valuepos) : a:expr
  let value = valuepos >= 0 ? strpart (a:expr, valuepos + 1) : ''

  " Return list with both strings
  return [name, value]

endfunction


function! s:EvaluateReservedVariable (name, value, variables)

  let result = ''

  if a:name == 'date'
    let result = strftime (empty (a:value) ? g:jpTemplateDateFormat : a:value)
  elseif a:name == 'shell'
    if !empty (a:value)
      let result = system (a:value)
    endif
  elseif a:name == 'interactive_shell'
    let command = input ('interactive_shell: ', a:value)
    if !empty (command)
      let result = system (command)
    endif
  elseif a:name == 'execute'
    if !empty (a:value)
      execute a:value
    endif
  elseif a:name == 'call'
    if !empty (a:value)
      let result = call (a:value, [], a:variables)
    endif
  endif

  return result

endfunction


function! s:ExpandTemplate (info, template)

  " Backup content before and after the template name
  let before = strpart (getline ('.'), 0, a:info['start'])
  let after  = strpart (getline ('.'), a:info['end'])

  " Merge lines of the template and then split them up again.
  " This makes multi-line variable values possible
  let mergedTemplate = split (join (a:template, "\n"), "\n")

  " Define cnt as the number of inserted lines
  let cnt = 0

  " Remove template string if the resulting template is empty
  if empty (mergedTemplate)
    call setline (line ('.'), before . after)
    call cursor (line ('.'), len (before) + 1)
    let cnt = -1
  else
    " Insert template between before and after
    for cnt in range (0, len (mergedTemplate) - 1)
      if cnt == 0
        call setline (line ('.'), before . mergedTemplate[cnt])
      else
        call append (line ('.') + cnt - 1, a:info['indent'] . mergedTemplate[cnt])
      endif
      if cnt == len (mergedTemplate) - 1
        call setline (line ('.') + cnt, getline (line ('.') + cnt) . after)
      endif
    endfor
  endif

  " Define start and end columns of the template
  let startColumn = len (before)
  if empty (mergedTemplate)
    let endColumn = startColumn
  else
    if cnt == 0
      let endColumn = startColumn + len (mergedTemplate[0])
    else
      let endColumn = len (a:info['indent'] . mergedTemplate[len (mergedTemplate) - 1])
    endif
  endif

  " Return number of inserted lines, start and end columns
  return [cnt, startColumn, endColumn]

endfunction


function! s:ProcessTemplate (info, template)

  let matchpos    = 0
  let expressions = []
  let variables   = {}
  let reserved    = {}

  " Make a string out of the template lines
  let s:str = join (a:template, ' ')

  " Detect all variable names of the template
  while 1
    " Find next variable start and end position
    let start = match    (s:str, '${[^{}]\+}', matchpos)
    let end   = matchend (s:str, '${[^{}]\+}', matchpos)

    if start < 0
      " Stop search if there is no variable left
      break
    else
      " Extract variable expression (remove '${' and '}')
      let expr = s:str[start+2 : end-2]

      " Extract variable name and default value */
      let [name, value] = s:ParseExpression (expr)

      if name == 'cursor'
        " Skip the ${cursor} variable
      elseif count (s:reservedVariables, name) > 0
        let reserved[expr] = ''
      else
        " Only insert variables on their first appearance
        if !has_key (variables, name)
          " Add expression to the expression list
          call add (expressions, expr)

          " Set variable value to ''
          let variables[name] = ''
        endif

        " Check whether local default value is defined or not
        if empty (value)
          " If not, check if variable value is empty
          if empty (variables[name])
            " If so, either set it to the last remembered value or the global
            " default if it exists
            if has_key (s:rememberedValues, name)
              let variables[name] = s:rememberedValues[name]
            elseif has_key (g:jpTemplateDefaults, name)
              let variables[name] = g:jpTemplateDefaults[name]
            endif
          endif
        else
          " Use local default (first occurence in the template only)
          let variables[name] = value
        endif
      endif

      " Start next search at the end position of this expression
      let matchpos = end
    endif
  endwhile

  " Ask the user to enter values for all variables
  for expr in expressions
    let [name, value] = s:ParseExpression (expr)
    let variables[name] = input (name . ': ', variables[name])
    let s:rememberedValues[name] = variables[name]
  endfor

  " Evaluate reserved variables
  for expr in keys (reserved)
    let [name, value] = s:ParseExpression (expr)
    let replacement = s:EvaluateReservedVariable (name, value, variables)
    let reserved[expr] = replacement
  endfor

  " Expand all variables (custom and reserved)
  for index in range (len (a:template))
    for expr in expressions
      let [name, value] = s:ParseExpression (expr)
      let expr = '${' . name . '\(:[^{}]\+\)\?}'
      let value = escape(variables[name], s:escapeCharacters)
      let a:template[index] = substitute (a:template[index], expr, value, 'g')
    endfor

    for [expr, value] in items (reserved)
      let expr = '${' . expr . '}'
      let value = escape(value, s:escapeCharacters)
      let a:template[index] = substitute (a:template[index], expr, value, 'g')
    endfor
  endfor

  " Insert template into the code line by line
  let [insertedLines, startColumn, endColumn] = s:ExpandTemplate (a:info, a:template)

  " Update the cursor position and return to insert mode 
  call s:UpdateCursorPosition (insertedLines, endColumn)

endfunction

function! ReplaceCurrentLine()
	let info = s:GetTemplateInfo()
	let n = line('.')
	let end = col('.') - 1 - len(info['name']) - 1
	normal ^
	let start = col('.') - 1
	let line = getline('.')
	if start > 0
		call setline(n, line[0 : start - 1])
	else
		call setline(n, '')
	endif
	return line[start : end]
endfunction


function! InsertTemplate ()

  try
    " Detect bounds of the template name as well as the name itself
    let info = s:GetTemplateInfo ()

    " Load the template file
    let template = s:ReadTemplate (info['name'], info['filename'])

    " Do the hard work: Process the template
    call s:ProcessTemplate (info, template)
  catch
    " Inform the user about errors
    echo g:jpTemplateVerbose ? v:exception . " (in " . v:throwpoint . ")" : v:exception
  endtry

endfunction


" Initialize jptemplate configuration
call s:Initialize ()

" Map keyboard shortcut to the template system
exec 'imap ' . g:jpTemplateKey . ' <Esc>:call InsertTemplate()<CR>'
