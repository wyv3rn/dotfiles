" Vundle plugin manager
set nocompatible
filetype off

" redefine the mapleader key to Space
nnoremap <Space> <Nop>
let mapleader = "\<Space>"

" general stuff
syntax enable
set gdefault
set ignorecase
set smartcase
set incsearch
set hlsearch
set ruler
set vb
set background=dark
set autoindent
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set wildmenu
set rnu
set grepprg=grep\ -nH\ $*
set path+=**
set ttyfast
set showcmd
set scrolloff=5
set novisualbell
set undofile
set undodir=$HOME/.vim/undo
set undolevels=1000
set backspace=indent,eol,start
au BufNewFile,BufRead SCons* set filetype=python
au BufNewFile,BufRead Doxyfile set filetype=conf
nnoremap <leader>u :up<CR>
let g:netrw_banner=0

set timeoutlen=750
set ttimeoutlen=10

" open files at last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g`\"zz" | endif
endif

" highlight stuff
hi MatchParen cterm=none ctermbg=none ctermfg=red
hi SpellBad cterm=underline ctermbg=none ctermfg=red
hi LineNr ctermfg=darkgrey
hi CursorLineNR cterm=bold

" cursor shape and blink
let escPrefix = ""
let escSuffix = ""
if exists('$TMUX')
    let escPrefix = "\<ESC>Ptmux;\<ESC>"
    let escSuffix = "\<ESC>\\"
endif
let &t_SI = escPrefix . "\<Esc>[5 q" . escSuffix
let &t_SR = escPrefix . "\<Esc>[3 q" . escSuffix
let &t_EI = escPrefix . "\<Esc>[1 q" . escSuffix
set guicursor+=a:blinkon1

" Turn off highlighting and clear any message already displayed.
:nnoremap <silent> <leader>c :nohlsearch<Bar>:echo<CR>

" trailing whitespaces
hi ExtraWhitespace cterm=none ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
nnoremap <leader>Tw ms:%s/\s\+$//<CR>`s

" filetype stuff
filetype plugin indent on

" copy/paste from clipboard (requires xclip on X or wl-copy/wl-paste on Wayland)
vnoremap <leader>y "+y
nnoremap <leader>p "+gP

" Autoformat
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
