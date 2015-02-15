let s:url="http://localhost:6080/api/v1/search?stats=fosho&rng=20&files=.*&i=nope&q="
let g:hound_verbose=1
let g:hound_repos="*"

function! Hound(query_string) abort

  let output = s:url . "\n\n"
  let curl_response=system('curl -s "'.s:url.a:query_string.'&repos='.g:hound_repos.'"')
  let s:response = webapi#json#decode(curl_response)

  let repos = []

  for tuple in items(s:response["Results"])
      let repos += [tuple[0]]
  endfor

  for repo in repos
      let output .= "Repo: " . repo . "\n================================================\n"
      for mymatch in s:response["Results"][repo]["Matches"]
          for mymatch2 in mymatch["Matches"]
              let output.="\n".mymatch["Filename"]
                          \.":".mymatch2["LineNumber"]
                          \."\n--------------------------------------------------------------"
                          \."\n"
              if g:hound_verbose
                  let output.=join(mymatch2["Before"], "\n")
                              \.mymatch2["Line"]
                              \.join(mymatch2["After"], "\n")."\n"
              else
                  let output.=substitute(mymatch2["Line"], '^\s*\(.\{-}\)\s*$', '\1', '') . "\n"
              endif
              let output.="\n"
          endfor
      endfor
  endfor

  :redir! @a | silent echo output | redir END |
  :enew  | normal "apgg2ddGddgg
endfunction

command! -nargs=1 Hound call Hound(<f-args>)
" nnoremap <LEADER>* yiw exec "Hound " . @= <CR>
