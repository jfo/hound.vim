if !exists('g:hound_base_url')
    let g:hound_base_url="http://127.0.0.1"
endif

if !exists('g:hound_port')
    let g:hound_port="6080"
endif

if !exists('g:hound_repos')
    let g:hound_repos="*"
    if exists('g:hound_repo_paths')
        let g:hound_repos = join(keys(g:hound_repo_paths), ",")
    endif
endif

if !exists('g:hound_repo_paths')
    let g:hound_repo_paths = {}
endif

if !exists('g:hound_verbose')
    " defaults to true; 0 is falsy; vimscript has no booleans yay vimscript o_O
    let g:hound_verbose=1
endif

if !exists('g:hound_vertical_split')
    let g:hound_vertical_split=0
endif

if !exists('g:hound_preserve_repo_case')
    let g:hound_preserve_repo_case=0
endif

if !exists('g:hound_ignore_case')
    let g:hound_ignore_case=0
endif

function! hound#encodeUrl(string) abort
    let mask = "[ \\]'\!\#\$&(),\*\+\/:;=?@\[]"
    return substitute(a:string, mask, '\=printf("%%%x", char2nr(submatch(0)))', 'g')
endfunction

function! hound#buildWebUrl(query_string, clean_repos)
    let sanitized_query_string = hound#encodeUrl(a:query_string)

    return g:hound_base_url . ':' . g:hound_port
                \. '?repos=' . a:clean_repos
                \. '&i=' . g:hound_ignore_case
                \. '&q=' . sanitized_query_string

endfunction

function! hound#fetchResults(query_string, clean_repos)
    let sanitized_query_string = hound#encodeUrl(a:query_string)

    if g:hound_preserve_repo_case
      let clean_repos = substitute(g:hound_repos, " ","","g")
    else
      let clean_repos = substitute(tolower(g:hound_repos), " ","","g")
    endif

    let s:api_full_url = g:hound_base_url
                \. ":" . g:hound_port
                \. '/api/v1/search?'
                \. '&repos=' . a:clean_repos
                \. '&i=' . g:hound_ignore_case
                \. '&q=' . sanitized_query_string

    let s:curl_response=system('curl -s "'.s:api_full_url.'"')

    try
        let response = webapi#json#decode(s:curl_response)
    catch
        throw "Hound could not connect to " . g:hound_base_url . ":" . g:hound_port
    endtry

    if (has_key(response, 'Error'))
        throw "Hound server error: " . response["Error"]
    endif

    return response
endfunction

function! hound#getRepoBasePath(repo_name)
    if !empty(g:hound_repo_paths) && has_key(g:hound_repo_paths, a:repo_name)
        return fnamemodify(g:hound_repo_paths[a:repo_name], ":p")
    endif
    return ""
endfunction

function! HoundQF(...) abort
    let query_string = join(a:000)

    if empty('g:hound_repo_paths')
        echo "You must set g:hound_repo_paths in your vimrc to use HoundQF"
        return
    endif

    if g:hound_preserve_repo_case
      let clean_repos = substitute(join(keys(g:hound_repo_paths), ','), " ","","g")
    else
      let clean_repos = substitute(tolower(join(keys(g:hound_repo_paths), ',')), " ","","g")
    endif

    try
        let response = hound#fetchResults(query_string, clean_repos)
    catch
        echoerr v:exception
    endtry

    let repos = []
    for tuple in items(response["Results"])
        let repos += [tuple[0]]
    endfor

    let qflist = []

    for repo in repos
        let repo_base_path = hound#getRepoBasePath(repo)

        for file_match in response["Results"][repo]["Matches"]
            for line_match in file_match['Matches']
                let qfitem = {
                    \'filename': repo_base_path . file_match["Filename"],
                    \'lnum': line_match["LineNumber"],
                    \'pattern': '',
                    \'text': line_match["Line"], }
                call add(qflist, qfitem)
            endfor
        endfor
    endfor

    if empty(qflist)
        echo "Nothing for you, Dawg"
    else
        call setqflist(qflist)
        copen
    end
endfunction

function! Hound(...) abort

    let query_string = join(a:000)

    if g:hound_preserve_repo_case
      let clean_repos = substitute(g:hound_repos, " ","","g")
    else
      let clean_repos = substitute(tolower(g:hound_repos), " ","","g")
    endif

    try
        let response = hound#fetchResults(query_string, clean_repos)
    catch
        echoerr v:exception
    endtry

    let s:web_full_url = hound#buildWebUrl(query_string, clean_repos)
    let s:output = s:web_full_url

    let repos = []
    for tuple in items(response["Results"])
        let repos += [tuple[0]]
    endfor

    for repo in repos
        let repo_base_path = hound#getRepoBasePath(repo)

        let s:output .= "\n\nRepo: " . repo . "\n================================================================================\n"
        for file_match in response["Results"][repo]["Matches"]
            for line_match in file_match["Matches"]
                let s:output.="\n".repo_base_path.file_match["Filename"]
                            \.":".line_match["LineNumber"]
                            \."\n--------------------------------------------------------------------------------\n"
                if g:hound_verbose
                    let s:output.=join(line_match["Before"], "\n")
                                \. "\n" . line_match["Line"] . "\n"
                                \.join(line_match["After"], "\n")."\n"
                else
                    let s:output.=substitute(line_match["Line"], '^\s*\(.\{-}\)\s*$', '\1', '') . "\n"
                endif
                let s:output.="\n"
            endfor
        endfor
    endfor

    if (s:output == s:web_full_url)
        echo "Nothing for you, Dawg"
    else
        if g:hound_vertical_split
            execute ":vnew ". tempname()
        else
            execute ":edit ". tempname()
        endif

        normal! ggdG
        setlocal filetype=houndresults | setlocal nowrap | setlocal buftype=nofile
        call append(0, split(s:output, '\n'))
        normal! gg

        if g:hound_ignore_case == 1
            let l:query = '\c' . query_string
        else
            let l:query = query_string
        endif
        exec 'syntax match queryString "'.l:query.'"'
        highlight link queryString DiffAdd

        syntax match FilePath "^.*\(\n-----\)\@="
        highlight link FilePath Special

    endif
endfunction

command! -nargs=1 Hound call Hound(<f-args>)
command! -nargs=1 HoundQF call HoundQF(<f-args>)
