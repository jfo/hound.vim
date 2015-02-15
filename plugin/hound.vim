if !exists('g:hound_base_url')
    let g:hound_base_url="http://127.0.0.1"
endif

if !exists('g:hound_port')
    let g:hound_port="6080"
endif

if !exists('g:hound_repos')
    let g:hound_repos="*"
else
    let g:hound_repos=tolower(g:hound_repos)
endif

if !exists('g:hound_verbose')
    " defaults to false; 0 is falsy; vimscript has no booleans yay vimscript o_O
    let g:hound_verbose=0
endif

function! Hound(query_string) abort
  let s:api_full_url = g:hound_base_url
              \. ":" . g:hound_port
              \. '/api/v1/search?'
              \.'&repos=' . g:hound_repos
              \. '&q=' . a:query_string

  let s:web_full_url = g:hound_base_url . ':' . g:hound_port
              \.'?repos=' . g:hound_repos
              \. '&q=' . a:query_string . "\n\n"

  let s:curl_response=system('curl -s "'.s:api_full_url.'"')

  try
      let s:response = webapi#json#decode(s:curl_response)
  catch
      echoerr "Hound could not connect to " . g:hound_base_url . ":" . g:hound_port
  endtry

  let s:output = s:web_full_url

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

  if (s:output == s:web_full_url)
      echo "Nothing for you, Dawg"
  else
      if (bufwinnr("__Hound_Results__") > 0)
          :edit __Hound_Results__
      else
          :vsplit __Hound_Results__
      endif

      normal! ggdG
      setlocal filetype=houndresults | setlocal buftype=nofile | setlocal nowrap
      call append(0, split(s:output, '\n'))
      normal! gg

      exec 'syntax match queryString "'.a:query_string.'"'
      highlight link queryString DiffAdd

      syntax match FilePath "^.*\(\n-----\)\@="
      highlight link FilePath Special

  endif
endfunction

command! -nargs=1 Hound call Hound(<f-args>)
