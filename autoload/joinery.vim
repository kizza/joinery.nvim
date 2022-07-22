if get(s:, 'loaded')
  finish
endif
let s:loaded = 1

function joinery#toggle()
  let l:ranges = v:lua.require'joinery'.get_partitioned_ranges()
  if l:ranges is v:null || len(l:ranges) == 0
    echo "No range found"
    return
  end

  " Inspect the range
  let [callable; blocks] = l:ranges
  let [line_start, _, line_end, _] = callable
  let l:block = v:null
  if len(blocks) == 1
    let l:block = blocks[0]
  endif

  " Execute
  if line_start != line_end
    call joinery#join(callable)
  else
    call joinery#split(callable, l:block)
  end
endfunction

function joinery#join(range)
  " Join the callable range
  let [line_start, _, line_end, _] = a:range
  execute(line_start ."," . line_end ."call joinery#join_lines_without_spaces()")

  " Indent the block (after the join)
  let [callable; blocks] = v:lua.require'joinery'.get_partitioned_ranges()

  " Unindent block if found
  if len(blocks) == 1
    let l:cursor = getpos(".")
    let [line_start, _, line_end, _] = blocks[0]
    execute(line_start + 1 ."," . line_end ."normal <<")
    call setpos(".", l:cursor)
  end

  " If within brackets (on surrounding lines) execute ArgWrap
  let [line_start, column_start, line_end, column_end] = callable
  if joinery#argwrap#enabled() && joinery#util#is_within_block_brackets(line_start)
    call joinery#argwrap#execute()
  endif
endfunction

function joinery#split(range, block)
  " Get wrapped content
  let [prefix, body, suffix] = joinery#util#parse_line(a:range)
  let l:wrapped = joinery#split_line(body)

  " Prefix each wrapped line with existing indent
  let l:existing_indent = matchstr(prefix, '\_^\s*')
  let l:wrapped = substitute(l:wrapped, "\n", "\n".l:existing_indent, "g")
  let l:new_line_count = count(l:wrapped, "\n")

  " Noop?
  if l:new_line_count == 0
    return
  endif

  " If within brackets (and using Vim-ArgWrap execute that first)
  let [line_start, column_start, line_end, column_end] = a:range
  if joinery#argwrap#enabled() && joinery#util#is_within_line_brackets(line_start, column_start)
    call joinery#argwrap#execute()
    redraw
    call joinery#toggle()
    return
  endif

  " Place into buffer
  " let [line_start; _rest] = a:range
  call joinery#util#setlines(line_start, prefix . l:wrapped . suffix)

  " Calculate line lengths to indent
  let l:block_line_length = 0
  if a:block isnot v:null
    let [line_start, _, line_end, _] = a:block
    let l:block_line_length = line_end - line_start
  endif

  " Indent
  let l:cursor = getpos(".")
  let l:indent_start = line_start + 1
  let l:indent_end = l:indent_start + (l:new_line_count - 1) + l:block_line_length
  execute(l:indent_start  ."," . l:indent_end ."normal >>")
  call setpos(".", l:cursor)
endfunction

" Split at opening or closing parenthesis
function joinery#split_line(line)
  let l:acc = ""
  let l:chunks = split(a:line, '[(|\[|{|}|\]|)]\zs')
  let l:nested_index = 0

  for chunk in l:chunks
    let l:last_char = chunk[-1:]

    " Without a delimeter, just accumulate
    if chunk!~"."
      let l:acc = l:acc . chunk
    " If in a nested context, just accumulate
    elseif l:nested_index > 0
      let l:acc = l:acc . chunk
    " Split at delimeter
    else
      let l:acc = l:acc . joinery#insert_new_lines(chunk)
    endif

    " Calculate the nesting level for next iteration
    if joinery#util#is_opening_char(l:last_char)
      let l:nested_index += 1
    elseif joinery#util#is_closing_char(l:last_char)
      let l:nested_index -= 1
    endif
  endfor

  return l:acc
endfunction

" Add new lines at ?.
function joinery#insert_new_lines(text)
  return substitute(a:text, '\(&\?\.\)', "\n\\1", "g")
endfunction

function! joinery#join_lines_without_spaces() range
  for i in range(a:firstline, a:lastline)
    if i != a:lastline
      execute "normal J"
      if joinery#util#char_under_cursor() == " "
        execute "normal x"
      end
    end
  endfor
endfunction
