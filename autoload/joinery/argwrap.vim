function joinery#argwrap#enabled()
  return v:false
  return &filetype == "ruby" && exists(":ArgWrap")
endfunction

function joinery#argwrap#execute()
  execute ":ArgWrap"
endfunction

