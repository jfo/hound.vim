let g:hound_base_url="http://localhost"
let g:hound_port="6080"
let g:hound_repos="*"

let g:hound_verbose=0
let g:hound_repos="*"

function! Hound(query_string) abort

  let s:full_url = g:hound_base_url
              \. ":" . g:hound_port
              \. '/api/v1/search?'
              \.'&repos=' . g:hound_repos
              \. '&q=' . a:query_string

  let s:curl_response=system('curl -s "'.s:full_url.'"')
  let s:response = webapi#json#decode(s:curl_response)

  let s:output = s:full_url

  let repos = []
  for tuple in items(s:response["Results"])
      let repos += [tuple[0]]
  endfor

  for repo in repos
      let s:output .= "Repo: " . repo . "\n================================================================================\n"
      for mymatch in s:response["Results"][repo]["Matches"]
          for mymatch2 in mymatch["Matches"]
              let s:output.="\n".mymatch["Filename"]
                          \.":".mymatch2["LineNumber"]
                          \."\n--------------------------------------------------------------------------------\n"
              if g:hound_verbose
                  let s:output.=join(mymatch2["Before"], "\n")
                              \.mymatch2["Line"]
                              \.join(mymatch2["After"], "\n")."\n"
              else
                  let s:output.=substitute(mymatch2["Line"], '^\s*\(.\{-}\)\s*$', '\1', '') . "\n"
              endif
              let s:output.="\n"
          endfor
      endfor
  endfor

  :redir! @a | silent echo s:output | redir END |
  :enew | normal "apgg2ddGddgg
  :setlocal nowrap

endfunction

command! -nargs=1 Hound call Hound(<f-args>)
" nnoremap <LEADER>* yiw exec "Hound " . @= <CR>
