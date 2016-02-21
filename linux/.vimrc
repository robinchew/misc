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
set iskeyword-=-
"au Syntax python source ~/.vim/syntax/mine.vim
hi Search ctermfg=White
"set list
"set listchars=tab:▸\ ,
set hlsearch

"Jump n lines and down the page without moving the cursor 
nnoremap <PageUp> 10<C-y>
nnoremap <PageDown> 10<C-e>
"set clipboard=unnamedplus
let g:paredit_electric_return = 0

set backup
set swapfile
set backupdir=~/.vim-tmp
set directory=~/.vim-tmp

"Disable automatic comment insertion
"http://vim.wikia.com/wiki/Disable_automatic_comment_insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

execute pathogen#infect()
