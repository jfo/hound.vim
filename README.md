hound.vim
=========

A plugin to talk to Etsy's [Hound](https://github.com/etsy/Hound) trigram search.

Installation
-------------
[Vundle](https://github.com/gmarik/Vundle.vim) or [Pathogen](https://github.com/tpope/vim-pathogen)

Dependencies
-------------
This plugin requires:

[webapi-vim](https://github.com/mattn/webapi-vim) and `curl`

Description
-------------

Introduces the

```
:Hound
```

command, which takes a string and asks a hound server: "like hey what's up with this string?" and presents the results in a scratch buffer.

You can also get the results in a quickfix window by running
```
HoundQF <searchterm>
```

hound.vim assumes you have a server running on localhost at port 6080. If you want to hit somewhere else you can redefine either in your .vimrc:

```vimscript
let g:hound_base_url = "arbitrary.url.com"
let g:hound_port = "6081"
```
You can also limit which repos you search through with (case insensitive) comma separated strings:

```vimscript
let g:hound_repos = "arepo,anotherrepo,anynumberofrepos"
```

You can tell hound.vim where your repositories live, by specifying a lower case
dictionary like so:
```vimscript
 let g:hound_repo_paths = {
    \'arepo': '/path/to/arepo',
    \'anotherrepo': '~/path/to/anotherrepo',}
```

If your repos have uppercase letters, please specify them with capitals in `g:hound_repos` and `g:hound_repo_paths`, and set:

```vimscript
let g:hound_preserve_repo_case = 1
```

This dictionary is required in order to use the `HoundQF` command.

To ignore case in searches by default:

```vimscript
let g:hound_ignore_case = 1
```

I also recommend a mapping such as

```vimscript
nnoremap <leader>a :Hound<space>
```
for quick access.

If you want a vertical split instead of a new window:
```vimscript
let g:hound_vertical_split = 1
```

Doge
------
<img src="https://i.imgflip.com/hoo6z.jpg" alt="dogehound" style="width: 200px;"/>
