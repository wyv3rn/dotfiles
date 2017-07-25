" automatically load plugins
execute pathogen#infect()
so ~/.vim/bundle/vimlatx.vim/plugin/imaps.vim

" general stuff
syntax enable
set ruler
set vb
set background=dark
set autoindent
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set ignorecase
set incsearch
set hlsearch
set rnu
set grepprg=grep\ -nH\ $*
set path+=**

" gui stuff
if has('gui_running')
    colorscheme solarized
    set background=dark
    inoremap <C-Space> <C-n>
    set guicursor=a:blinkon600-blinkoff400  " Slow down cursor blinking speed
    set guifont=Inconsolata\ 11
    set novisualbell
    set guioptions-=T
    set guioptions-=r
    set guioptions-=L
else
    highlight LineNr ctermfg=darkgrey
    inoremap <Nul> <C-n>
endif

" trailing whitespaces
highlight ExtraEhitespace ctermbg=red guibg=red
match ExtraEhitespace /\s\+$/
nnoremap <leader>rt :%s/\s\+$//<CR>

" filetype stuff
filetype plugin indent on
au FileType ruby setl sw=2 sts=2
au Filetype tex setl nofoldenable

" redefine the mapleader key
let mapleader = "m"

" Press Space to turn off highlighting and clear any message already displayed.
:nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" moving lines up and down
nnoremap <C-S-Down> :m .+1<CR>==
nnoremap <C-S-Up> :m .-2<CR>==
inoremap <C-S-Down> <Esc>:m .+1<CR>==gi
inoremap <C-S-Up> <Esc>:m .-2<CR>==gi
vnoremap <C-S-Down> :m '>+1<CR>gv=gv
vnoremap <C-S-Up> :m '<-2<CR>gv=gv

" convenient saving
nnoremap <C-s> :w<CR>
inoremap <C-s> <ESC>:w<CR>

" execute local vimrc files as well
if filereadable(".vimrc.local")
    so .vimrc.local
endif

" moving around
noremap <C-Down> }
noremap <C-Up> {

" tag jumping
nnoremap ä g<C-]>
nnoremap ö <C-t>

" vimlatex
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_MultipleCompileFormats='pdf'

" nerdcommenter
let g:NERDSpaceDelims = 1
map <leader>cl <plug>NERDCommenterComment
map <leader>cc <plug>NERDCommenterAlignLeft

