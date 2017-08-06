" Vundle plugin manager
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'mileszs/ack.vim'
Plugin 'wincent/command-t'
Plugin 'roman/golden-ratio'
Plugin 'scrooloose/nerdcommenter'
Plugin 'lyuts/vim-rtags'
Plugin 'tpope/vim-surround'
Plugin 'benmills/vimux'
Plugin 'vim-latex/vim-latex'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'Valloric/YouCompleteMe'
call vundle#end()

" redefine the mapleader key
let mapleader = "m"

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

" cursor shape TODO compatible with iterm2?
let escPrefix = ""
let escSuffix = ""
if exists('$TMUX')
    let escPrefix = "\<ESC>Ptmux;\<ESC>"
    let escSuffix = "\<ESC>\\"
endif
let &t_SI = escPrefix . "\<Esc>[5 q" . escSuffix
let &t_SR = escPrefix . "\<Esc>[3 q" . escSuffix
let &t_EI = escPrefix . "\<Esc>[1 q" . escSuffix

" gui stuff
if has('gui_running')
    colorscheme solarized
    set background=dark
    inoremap <C-Space> <C-n>
    set guicursor=a:blinkon600-blinkoff400  " Slow down cursor blinking speed
    set guifont=DejaVu\ Sans\ Mono\ 9
    set antialias
    set guioptions-=m
    set guioptions-=e
    set guioptions-=T
    set guioptions-=r
    set guioptions-=L
else
    highlight LineNr ctermfg=darkgrey
    inoremap <Nul> <C-n>
endif

" window stuff
nnoremap <leader>wn <C-w>v<C-w>l
nnoremap <leader>wf <C-w>v:e .<CR>
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
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
nnoremap <leader>rtw :%s/\s\+$//<CR>

" filetype stuff
filetype plugin indent on
au FileType ruby setl sw=2 sts=2
au Filetype tex setl nofoldenable

" moving lines up and down
nnoremap <S-Down> :m .+1<CR>==
nnoremap <S-Up> :m .-2<CR>==
inoremap <S-Down> <Esc>:m .+1<CR>==gi
inoremap <S-Up> <Esc>:m .-2<CR>==gi
vnoremap <S-Down> :m '>+1<CR>gv=gv
vnoremap <S-Up> :m '<-2<CR>gv=gv

" convenient saving
nnoremap <C-s> :w<CR>
inoremap <C-s> <ESC>:w<CR>

" convenient copy/paste
vnoremap <C-c><C-c> "+y
nnoremap <C-c><C-v> "+gP

" moving around
noremap <C-Down> }
noremap <C-Up> {

" tag jumping with rtags
nmap ä <leader>rj
nmap ö <C-o>

" vimlatex and latex in general
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_MultipleCompileFormats='pdf'
set iskeyword+=:
so ~/.vim/bundle/vim-latex/plugin/imaps.vim
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

" tmux navigation integration
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-S-Left> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-S-Down> :TmuxNavigateDown<cr>
nnoremap <silent> <C-S-Up> :TmuxNavigateUp<cr>
nnoremap <silent> <C-S-Right> :TmuxNavigateRight<cr>

" vimux
nnoremap <Leader>p :VimuxPromptCommand<CR>

" execute local vimrc files as well
if filereadable(".vimrc.local")
    so .vimrc.local
endif
