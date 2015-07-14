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

hound.vim assumes you have a server running on localhost at port 6080. If you want to hit somewhere else you can redefine either in your .vimrc:

```vimscript
let g:hound_base_url = "arbitrary.url.com"
let g:hound_port = "6081"
```
You can also limit which repos you search through with (case insensitive) comma separated strings:

```vimscript
let g:hound_repos = "arepo,anotherrepo,anynumberofrepos"
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

This is a beta release. Please let me know of any bugs! There will be bugs! More docs and features and options to come.

Doge
------
<img src="https://i.imgflip.com/hoo6z.jpg" alt="dogehound" style="width: 200px;"/>
