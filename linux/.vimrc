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

"execute pathogen#infect()

" Below is a piece of shit way to set indentations per file type
" because by default it will make all files of whatever type
" autoindent and autocomment.
"
"filetype plugin indent on

" Disable automatic comment insertion
" But does it even fucking work when 'filetype plugin indent on'
" is set? Read above.
"http://vim.wikia.com/wiki/Disable_automatic_comment_insertion
"
"autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Most sensible way to set indentations per file type without
" the bullshit autoindent and autocommment for all file types by default.
" http://stackoverflow.com/questions/158968/changing-vim-indentation-behavior-by-file-type
autocmd FileType go setlocal shiftwidth=2 noexpandtab copyindent preserveindent softtabstop=0 shiftwidth=4 tabstop=4
