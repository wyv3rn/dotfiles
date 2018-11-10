" Vundle plugin manager
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
set rtp+=/usr/local/opt/fzf
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'mileszs/ack.vim'
Plugin 'junegunn/fzf.vim'
Plugin 'roman/golden-ratio'
Plugin 'scrooloose/nerdcommenter'
Plugin 'lyuts/vim-rtags'
Plugin 'tpope/vim-surround'
Plugin 'benmills/vimux'
Plugin 'vim-latex/vim-latex'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'Valloric/YouCompleteMe'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'vimwiki/vimwiki'
Plugin 'easymotion/vim-easymotion'
Plugin 'tpope/vim-repeat'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'skwp/greplace.vim'
Plugin 'fatih/vim-go'
Plugin 'wyv3rn/vim-tinycpp'

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
set backspace=indent,eol,start
au BufNewFile,BufRead SCons* set filetype=python

" open files at last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g`\"zz" | endif
endif

" highlight stuff
hi MatchParen cterm=none ctermbg=none ctermfg=red
hi SpellBad cterm=underline ctermbg=none ctermfg=red

" switch between light and dark background setting
map <F12> :let &background = ( &background == "dark"? "light" : "dark" )<CR>

" python: "else:" is the same as "else"
autocmd BufEnter,BufRead,BufNewFile *.py set iskeyword-=:

" cursor shape
let escPrefix = ""
let escSuffix = ""
if exists('$TMUX')
    let escPrefix = "\<ESC>Ptmux;\<ESC>"
    let escSuffix = "\<ESC>\\"
endif
let &t_SI = escPrefix . "\<Esc>[5 q" . escSuffix
let &t_SR = escPrefix . "\<Esc>[3 q" . escSuffix
let &t_EI = escPrefix . "\<Esc>[1 q" . escSuffix

" GUI stuff
if has('gui_running')
    colorscheme solarized
    set background=dark
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
endif

" correct last spelling error
imap <F2> <c-g>u<Esc>[s1z=`]a<c-g>u
nmap <F2> [s1z=<c-o>

" window and buffer stuff
nnoremap <leader>wn <C-w>v<C-w>l
nnoremap <leader>wf <C-w>v:e .<CR>
let g:netrw_banner=0
nnoremap <Tab> :e #<CR>

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
:nnoremap <silent> <Space>c :nohlsearch<Bar>:echo<CR>

" trailing whitespaces
hi ExtraWhitespace cterm=none ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
nnoremap <leader>rtw ms:%s/\s\+$//<CR>`s

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

" insert empty line in normal mode
nnoremap <leader>il o<Esc>d0

" convenient copy/paste
vnoremap <C-c><C-c> "+y
nnoremap <C-c><C-v> "+gP

" moving around
noremap <C-Down> }
noremap <C-Up> {
map <BS> k
map <C-h> k

" tag jumping with rtags
nmap ä <leader>rj
nmap ö <C-o>

" YCM
set completeopt-=preview
au FileType cpp map <F7> :YcmCompleter FixIt<CR>

" vimlatex and latex in general
nmap <F3> :w<CR><leader>ll
imap <F3> <ESC>:w<CR><leader>ll
imap <C-b> <Plug>IMAP_JumpForward
let g:latex_view_general_viewer = 'zathura'
let g:vimtex_view_method = 'zathura'
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_MultipleCompileFormats = 'pdf'
let g:Tex_IgnoredWarnings =
    \'Underfull'."\n".
    \'Overfull'."\n".
    \'Draft mode on'."\n".
    \'headheight is too small'."\n".
    \'Incompatible color definition on input line'."\n".
    \'Package amsmath Warning: Foreign command'."\n".
    \'You need to compile with XeLaTeX or Lua'."\n".
    \'Package Babel Warning: The package option'."\n".
    \'Marginpar'."\n".
    \'Font shape'
let g:Tex_IgnoreLevel = 10
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
au FileType tex call IMAP("z.b.", "z.\\,B{.}\\ ", "tex")
au FileType tex call IMAP("bzw.", "bzw{.}\\ ", "tex")
au FileType tex call IMAP(" eg ", " e.g.\\ ", "tex")
au FileType tex call IMAP(" ie ", " i.e.\\ ", "tex")
au FileType tex call IMAP("et al.", "et al{.}\\ ", "tex")
au FileType tex call IMAP("et al ", "et al{.}\\ ", "tex")

function! SyncTexForward()
    let execstr = "silent !zathura --synctex-forward ".line(".").":".col(".").":%:p %:p:r.pdf &"
    exec execstr
    redraw!
endfunction
au FileType tex nmap <Leader>lf :call SyncTexForward()<CR>


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
nnoremap <F4> :w<CR>:VimuxRunLastCommand<CR>
inoremap <F4> <ESC>:w<CR>:VimuxRunLastCommand<CR>

" fzf
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>

" greplace
set grepprg=ag
let g:grep_cmd_opts = '--line-numbers --noheading'

" ultisnips configuration
let g:UltiSnipsExpandTrigger="<C-d>"
let g:UltiSnipsJumpForwardTrigger="<C-e>"
let g:UltiSnipsJumpBackwardTrigger="<C-r>"
let g:UltiSnipsUsePythonVersion = 3

" easy motion stuff
let g:EasyMotion_smartcase = 1
let g:EasyMotion_keys = 'ratidubpsolgen'
map <Space> <Plug>(easymotion-prefix)
nmap <Space><Space> <Plug>(easymotion-sn)
nmap <Space>n <Plug>(easymotion-s2)
nmap <Space>r <Plug>(easymotion-bd-jk)

" TODO the general C/C++ stuff could be a plugin as well

nnoremap <leader>ch :TcSwitchHS<CR>
nnoremap <leader>cg :TcIncGuard<CR>
inoremap {<CR> {<CR>}<C-O>O
au FileType cpp set iskeyword-=:

" similar to deleting/changing inner and outer stuff: append to inner and outer stuff
" TODO this could be a small plugin ;) -> make register for the d commands configurable
:nnoremap <leader>ai( F(%i
:nnoremap <leader>aa( F(%a
:nnoremap <leader>ai[ F[%i
:nnoremap <leader>aa[ F[%a
:nnoremap <leader>ai{ F{%i
:nnoremap <leader>aa{ F{%a
:nnoremap <leader>ai" di"hpa
:nnoremap <leader>aa" di"hpla
:nnoremap <leader>ai' di'hpa
:nnoremap <leader>aa' di'hpla
:nnoremap <leader>ai< di<hpa
:nnoremap <leader>aa< di<hpla

" execute local vimrc files as well
if filereadable(".vimrc.local")
    so .vimrc.local
endif

