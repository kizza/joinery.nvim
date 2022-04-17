function joinery#util#setlines(line_start, text)
  let l:lines = split(a:text, "\n")
  for i in range(0, len(l:lines) - 1)
    if i == 0
      call setline(a:line_start, l:lines[i])
    else
      call append(a:line_start + (i -1), l:lines[i])
    endif
  endfor
endfunction

" Return the prefix, body and suffix of a single line range
function joinery#util#parse_line(range)
  let [line_start, column_start, line_end, column_end] = a:range
  let l:line = getline(line_start)
  let l:range = l:line[column_start - 1 : column_end -1]

  let l:prefix = ""
  if column_start > 1
    let l:prefix = l:line[0 : column_start - 2]
  endif

  let l:suffix = ""
  if column_end < strlen(l:line)
    let l:suffix = l:line[column_end :]
  endif

  return [l:prefix, l:range, l:suffix]
endfunction

function joinery#util#is_within_line_brackets(line, column)
  let l:line = getline(a:line)
  let l:chars = split(l:line, '\zs')
  let l:nested_index = 0

  for i in range(0, len(l:chars) - 1)
    let l:char = l:chars[i]
    if i  == a:column - 1
      if l:nested_index > 0
        return v:true
      else
        return v:false
      endif
    endif

    " Calculate the nesting level for next iteration
    if joinery#util#is_opening_char(l:char)
      let l:nested_index += 1
    elseif joinery#util#is_closing_char(l:char)
      let l:nested_index -= 1
    endif
  endfor
  return v:false
endfunction

function joinery#util#is_within_block_brackets(line)
  " Out of buffer range?
  if a:line == 1 || a:line == line("$")
    return v:false
  endif

  let l:previous_line_ending_char = getline(a:line - 1)[-1:]
  let l:next_line_starting_char = matchstr(getline(a:line + 1), '\S')

  return
    \ joinery#util#is_opening_char(l:previous_line_ending_char ) &&
    \ joinery#util#is_closing_char(l:next_line_starting_char )
endfunction

function joinery#util#char_under_cursor()
  return strcharpart(getline('.')[col('.') - 1:], 0, 1)
endfunction

function joinery#util#is_opening_char(char)
  return a:char == "(" || a:char == "[" || a:char == "{"
endfunction

function joinery#util#is_closing_char(char)
  return a:char == ")" || a:char == "]" || a:char == "}"
endfunction
