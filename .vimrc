" Load plugins configuration
if filereadable(expand("~/.vim/plugins.vim"))
  source ~/.vim/plugins.vim
endif

if filereadable(expand("~/.vim/lightline.vim"))
  source ~/.vim/lightline.vim
endif

if filereadable(expand("~/.vim/NERDTree.vim"))
  source ~/.vim/NERDTree.vim
endif

" Set no compatible with vi
set nocompatible

" Set history
set history=100

" Set undo history
set undolevels=150

" Enable syntax color
if has("syntax")
  syntax enable
  set background=dark
  colorscheme solarized
endif

" Option for backspace
set backspace=indent,eol,start

autocmd BufEnter * if expand("%:p:h") !~ '^/tmp' | silent! lcd %:p:h | endif

" Enable indentation guides
set listchars=space:·,eol:§,tab:¤›,extends:»,precedes:«,nbsp:‡

" Reread files when they have been changed out of vi
set autoread

" Disable sounds
set errorbells
set novisualbell
set t_vb=

" Search parameters
set incsearch
set noignorecase
set infercase
set hlsearch

" Display cursor
set ruler

" Set indentation
set cindent
