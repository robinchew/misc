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
"https://vim.fandom.com/wiki/Forcing_Syntax_Coloring_for_files_with_odd_extensions
autocmd BufNewFile,BufRead *.ex set syntax=elixir

command W w
command E e
command SSFS syntax sync fromstart
noremap Q <Esc>
noremap q <Esc>
set iskeyword-=_
set iskeyword-=-
"au Syntax python source ~/.vim/syntax/mine.vim
hi Search ctermfg=black
"set list
"set listchars=tab:▸\ ,
set hlsearch

"Jump n lines and down the page without moving the cursor 
nnoremap <PageUp> 10<C-y>
nnoremap <PageDown> 10<C-e>

" Ensure y, yy, d and dd does not copy to system clipboard
" https://stackoverflow.com/questions/38617304/how-to-disable-vim-pasting-to-from-system-clipboard
set clipboard=

" https://superuser.com/questions/271023/can-i-disable-continuation-of-comments-to-the-next-line-in-vim
:set formatoptions-=cro

" https://gist.github.com/u0d7i/01f78999feff1e2a8361
set mouse-=a

let g:paredit_electric_return = 0

"set backup " not sure why we need this in the first place, but having it causes hard links to break
set swapfile
set backupdir=~/.vim-tmp
set directory=~/.vim-tmp

"set statusline=%f\ %n

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
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
autocmd FileType dart setlocal shiftwidth=2 tabstop=2
