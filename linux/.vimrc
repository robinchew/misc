set ignorecase
set smartcase
syntax on
set sw=4
set tabstop=4
set smarttab
set expandtab
set autoindent
noremap r :%s:::g<left><left><left>
vnoremap r :s:::g<Left><Left><Left>
au! BufRead,BufNewFile *.module    set filetype=php
au! BufRead,BufNewFile *.ctp    set filetype=html
command W w
command E e
command SSFS syntax sync fromstart
noremap Q <Esc>
noremap q <Esc>
set iskeyword-=_
au Syntax python source ~/.vim/syntax/mine.vim
hi Search ctermfg=White
set list
set listchars=tab:▸\ ,
