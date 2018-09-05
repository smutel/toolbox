" Load plugins configuration
so ~/.vim/plugins.vim

" Lightline Options
set laststatus=2
if !has('gui_running')
  set t_Co=256
endif
let g:lightline = {
  \ 'colorscheme': 'wombat',
  \ }

" NERDTree Options
map <C-n> :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen = 1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let g:NERDTreeChDirMode = 2

" Enable syntax color
syntax enable
set background=dark
colorscheme solarized

" Option for backspace
set backspace=indent,eol,start

autocmd BufEnter * if expand("%:p:h") !~ '^/tmp' | silent! lcd %:p:h | endif
