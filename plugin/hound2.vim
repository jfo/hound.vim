let s:url="http://localhost:6080/api/v1/search?stats=fosho&rng=20&files=.*&i=nope&q="

function! Hound(query_string)

  let output = s:url . "\n\n"
  let curl_response=system('curl -s "http://localhost:6080/api/v1/search?stats=fosho&rng=20&files=.*&i=nope&q=' . a:query_string . '&repos=*"')
  let s:response = webapi#json#decode(curl_response)

  let repos = []

  for tuple in items(s:response["Results"])
      let repos = repos + [tuple[0]]
  endfor

  for repo in repos
      let output .= "Repo: " . repo . "\n================================================\n\n"
      for mymatch in s:response["Results"][repo]["Matches"]
          for mymatch2 in mymatch["Matches"]
            let output.=mymatch["Filename"]
                        \.":".mymatch2["LineNumber"]
                        \."\n"
                        \.substitute(mymatch2["Line"], '^\s*\(.\{-}\)\s*$', '\1', '') . "\n"
                        \."\n"
          endfor
      endfor
  endfor

  :redir! @a | silent echo output | redir END |
  :enew | normal "apgg2dd

endfunction

command! -nargs=1 Hound call Hound(<f-args>)
" nnoremap <LEADER>* yiw exec "Hound " . @= <CR>
