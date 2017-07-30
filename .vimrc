" automatically load plugins
execute pathogen#infect()

" redefine the mapleader key
let mapleader = "m"

" general stuff
set nocompatible
syntax enable
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

" window stuff
nnoremap <leader>wn <C-w>v<C-w>l
nnoremap <leader>wf <C-w>v:e .<CR>:vertical resize 85<CR>
let g:netrw_banner=0

" search and sub stuff
nnoremap / /\v
nnoremap <leader>sa :%s/\v
vnoremap <leader>sa :s/\v
nnoremap <leader>sl :s/\v
set gdefault
set ignorecase
set smartcase
set incsearch
set hlsearch

" Press Space to turn off highlighting and clear any message already displayed.
:nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" trailing whitespaces
highlight ExtraEhitespace ctermbg=red guibg=red
match ExtraEhitespace /\s\+$/
nnoremap <leader>rtw :%s/\s\+$//<CR>

" filetype stuff
filetype plugin indent on
au FileType ruby setl sw=2 sts=2
au Filetype tex setl nofoldenable

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

" convenient copy/paste
vnoremap <C-c><C-c> "+y
nnoremap <C-c><C-v> "+gP

" moving around
noremap <S-j> }
noremap <S-k> {

" tag jumping
nnoremap ä g<C-]>
nnoremap ö <C-t>

" vimlatex and latex in general
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_MultipleCompileFormats='pdf'
set iskeyword+=:
so ~/.vim/bundle/vimlatx.vim/plugin/imaps.vim
au FileType tex call IMAP("bib:", "\\cite{bib:<++>}<++>", "tex")
au FileType tex call IMAP("fig:", "\\autoref{fig:<++>}<++>", "tex")
au FileType tex call IMAP("ch:", "\\autoref{ch:<++>}<++>", "tex")
au FileType tex call IMAP("sec:", "\\autoref{sec:<++>}<++>", "tex")
au FileType tex call IMAP("sub:", "\\autoref{sub:<++>}<++>", "tex")
au FileType tex call IMAP("tab:", "\\autoref{tab:<++>}<++>", "tex")
au FileType tex call IMAP("ECH", "\\chapter{<++>}\<CR>\label{ch:<++>}\<CR>\<CR><++>\<CR>", "tex")
au FileType tex call IMAP("ESE", "\\section{<++>}\<CR>\label{sec:<++>}\<CR>\<CR><++>\<CR>", "tex")
au FileType tex call IMAP("ESU", "\\subsection{<++>}\<CR>\label{sub:<++>}\<CR>\<CR><++>\<CR>", "tex")

" nerdcommenter
let g:NERDSpaceDelims = 1
map <leader>cl <plug>NERDCommenterComment
map <leader>cc <plug>NERDCommenterAlignLeft

" ack
cnoreabbrev ack Ack!
if executable('ag')
      let g:ackprg = 'ag --vimgrep'
endif

" hardcore mode
let hardcore = 1
if hardcore
    map <Down> <Nop>
    map! <Down> <Nop>
    map <Up> <Nop>
    map! <Up> <Nop>
    map <Left> <Nop>
    map! <Left> <Nop>
    map <Right> <Nop>
    map! <Right> <Nop>
endif

" execute local vimrc files as well
if filereadable(".vimrc.local")
    so .vimrc.local
endif
