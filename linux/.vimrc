set ignorecase
set smartcase
syntax on
set sw=2
set tabstop=2
set smarttab
set expandtab
set autoindent
noremap r :%s:::g<left><left><left>
vnoremap r :s:::g<Left><Left><Left>
au! BufRead,BufNewFile *.module    set filetype=php
au! BufRead,BufNewFile *.ctp    set filetype=php
command W w
command E e
noremap Q <Esc>
noremap q <Esc>
set iskeyword-=_
