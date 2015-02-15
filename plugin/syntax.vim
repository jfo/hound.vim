function! Hound(query_string)
  exec 'enew | read! hound ' . a:query_string

  syn match filenames "^[^0-9|-].*"
  hi def link filenames String

  exec 'syn match string_query '.a:query_string
  hi def link string_query Keyword
  " hi def link filenames String
  :1
endfunction

command! -nargs=1 Hound call Hound(<f-args>)
" nnoremap <LEADER>* yiw exec "Hound " . @= <CR>
