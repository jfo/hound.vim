hound.vim
=========

A plugin to talk to Etsy's [Hound](https://github.com/etsy/Hound) trigram search.

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

Will dump your parsed results into a scratch buffer.

Please let me know of any bugs! There will be bugs!
