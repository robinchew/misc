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
"au Syntax python source ~/.vim/syntax/mine.vim
hi Search ctermfg=White
set list
set listchars=tab:▸\ ,

"Jump n lines and down the page without moving the cursor 
nnoremap <PageUp> 10<C-y>
nnoremap <PageDown> 10<C-e>

" Explain map, remap, noremap, nnoremap
" http://stackoverflow.com/questions/3776117/vim-what-is-the-difference-between-the-remap-noremap-nnoremap-and-vnoremap-ma

" For some reason home and end keys are not mapping properly.
" Home key
imap <esc>OH <esc>0i
cmap <esc>OH <home>
nmap <esc>OH 0
" End key
nmap <esc>OF $
imap <esc>OF <esc>$a
cmap <esc>OF <end>
