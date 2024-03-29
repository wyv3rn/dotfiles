" Vundle plugin manager
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
set rtp+=/usr/local/opt/fzf

" force all plugins to use python3
if has('python3')
endif

call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'mileszs/ack.vim'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-surround'
Plugin 'benmills/vimux'
Plugin 'vim-latex/vim-latex'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'ycm-core/YouCompleteMe'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'easymotion/vim-easymotion'
Plugin 'tpope/vim-repeat'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'skwp/greplace.vim'
Plugin 'fatih/vim-go'
Plugin 'rust-lang/rust.vim'
Plugin 'machakann/vim-swap'
Plugin 'Chiel92/vim-autoformat'
Plugin 'ElmCast/elm-vim'
Plugin 'wyv3rn/vim-tinycpp'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tpope/vim-fugitive'
Plugin 'dense-analysis/ale'
Plugin 'preservim/nerdtree'

call vundle#end()

" redefine the mapleader key to Space
nnoremap <Space> <Nop>
let mapleader = "\<Space>"

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
au BufNewFile,BufRead Doxyfile set filetype=conf
nnoremap <leader>u :up<CR>

set timeoutlen=750
set ttimeoutlen=10

" edit and reload config
nnoremap <leader>x :edit ~/.vimrc<CR>
nnoremap <leader>X :source ~/.vimrc<CR>

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

" switch between light and dark background setting
map <F12> :let &background = ( &background == "dark"? "light" : "dark" )<CR>

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

" better insert mode navigation
imap <c-b> <c-left>
imap <c-f> <c-right>
imap <c-h> <c-w>
" does not work for the last word, but not so important I guess (use <c-h>)
imap <c-g> <Right><Esc>dawi
imap <c-k> <Right><Esc>C

" match behavior of c-b and c-f in normal mode to insert mode
nmap <c-b> b
nmap <c-f> w

" GUI stuff
if has('gui_running')
    colorscheme solarized
    set background=dark
    set guifont=DejaVu\ Sans\ Mono\ 9
    set antialias
    set guioptions-=m
    set guioptions-=e
    set guioptions-=T
    set guioptions-=r
    set guioptions-=L
endif

" correct last spelling error
inoremap <F2> <c-g>u<Esc>[s1z=`]a<c-g>u
nnoremap <F2> [s1z=<c-o>

" Use and navigate quickfix list with ease
function! ToggleQuickFix()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
        copen
    else
        cclose
    endif
endfunction

" TODO [[ and ]] would be better
nnoremap <silent> [l :cprevious<CR>
nnoremap <silent> ]c :cnext<CR>
nnoremap <leader>tl :call ToggleQuickFix()<CR>

" window stuff
nnoremap <leader>ww <C-w>v<C-w>p
nnoremap <leader>ws <C-w>s<C-w>p
nnoremap <leader>wf <C-w>v<C-w>l:Files<CR>
nnoremap <leader>wb <C-w>v<C-w>l:Buffers<CR>
nnoremap <leader>wr <C-w>v<C-w>l:History<CR>
nnoremap <leader>w= <C-w>=
nnoremap <leader>wq <C-w>q
nnoremap <leader>wc <C-w>q
nnoremap <leader>y <C-w><C-p>
nnoremap <leader><Tab> <C-w><C-p>
nnoremap <leader>l <C-w>k
nnoremap <leader>e <C-w>l
nnoremap <leader>i <C-w>h
nnoremap <leader>a <C-w>j

let g:netrw_banner=0
nnoremap <Tab> :up<CR>:e #<CR>

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

" Turn off highlighting and clear any message already displayed.
:nnoremap <silent> <leader>c :nohlsearch<Bar>:echo<CR>

" trailing whitespaces
hi ExtraWhitespace cterm=none ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
nnoremap <leader>tw ms:%s/\s\+$//<CR>`s

" filetype stuff
filetype plugin indent on
au FileType ruby setl sw=2 sts=2
au Filetype tex setl nofoldenable
au FileType mail setl spell
au FileType mail setl spelllang=de

" moving lines up and down
nnoremap <S-Down> :m .+1<CR>==
nnoremap <S-Up> :m .-2<CR>==
inoremap <S-Down> <Esc>:m .+1<CR>==gi
inoremap <S-Up> <Esc>:m .-2<CR>==gi
vnoremap <S-Down> :m '>+1<CR>gv=gv
vnoremap <S-Up> :m '<-2<CR>gv=gv

" copy/paste from clipboard (requires xclip on X or wl-copy/wl-paste on Wayland)
vnoremap <C-c><C-c> "+y
nnoremap <C-c><C-v> "+gP

" moving around
noremap <C-Down> }
noremap <C-Up> {
map <BS> k
map <C-h> k
nnoremap <leader>m `m

" airline
let g:airline_theme='minimalist'
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.linenr = 'Ξ'
let g:airline_symbols.maxlinenr = ''
let g:airline_right_sep = ''

" YCM
set completeopt-=preview
let g:ycm_auto_hover=''
let g:ycm_extra_conf_globlist = ['~/gitlab/*', '~/github/*', '~/devops/*']
nmap <F7> :YcmCompleter FixIt<CR>
nmap gd :YcmCompleter GoTo<CR>
nmap <C-t> <C-o>
nmap <leader>t :YcmCompleter GetType<CR>
" TODO hover does not work?
nmap <leader>h <Plug>(YCMHover)
let g:ycm_semantic_triggers = {
     \ 'elm' : ['.'],
     \}
highlight YcmErrorLine ctermbg=Black
highlight YcmErrorSection ctermbg=Black
highlight YcmWarningLine ctermbg=Black
highlight YcmWarningSection ctermbg=Black


" vimlatex and latex in general
let g:tex_flavor='latex'
au FileType tex nmap <F9> :up<CR>:call VimuxRunCommand("clear; if [ -f Makefile ]; then make; else latexmk -pdf; fi")<CR>
imap <C-j> <Plug>IMAP_JumpForward
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
    \'Font shape'."\n".
    \'There is no short form set for acronym'."\n".
    \'Package fixltx2e Warning: fixltx2e is not required'."\n".
    \'Package multicol Warning: May not work with the twocolumn option'."\n".
    \'Package hyperref Warning: Token not allowed in a PDF'."\n".
    \'LaTeX Font Warning: Size substitutions'."\n".
    \'Package balance Warning: You have called'
let g:Tex_IgnoreLevel = 16
set iskeyword+=:
so ~/.vim/bundle/vim-latex/plugin/imaps.vim
au FileType tex call IMAP("bib:", "\\cite{bib:<++>}<++>", "tex")
au FileType tex call IMAP("fig:", "\\autoref{fig:<++>}<++>", "tex")
au FileType tex call IMAP("ch:", "\\autoref{ch:<++>}<++>", "tex")
au FileType tex call IMAP("sec:", "\\autoref{sec:<++>}<++>", "tex")
au FileType tex call IMAP("sub:", "\\autoref{sub:<++>}<++>", "tex")
au FileType tex call IMAP("tab:", "\\autoref{tab:<++>}<++>", "tex")
au FileType tex call IMAP("eq:", "\\autoref{eq:<++>}<++>", "tex")
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
au FileType tex nmap <leader>lf :call SyncTexForward()<CR>
au FileType tex silent! nunmap <buffer> <leader>rf

" nerdcommenter
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
noremap <leader>cc <plug>NERDCommenterComment
noremap <leader>cu <plug>NERDCommenterUncomment

" nerdtree
nnoremap <leader>tt :NERDTreeToggle<CR>
let NERDTreeWinSize = 52
" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
            \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif
" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif


" ack config
cnoreabbrev ack Ack!
let g:ackprg = 'rg --vimgrep --type-not sql --smart-case'
let g:ack_autoclose = 1
let g:ack_use_cword_for_empty_search = 1
nnoremap <leader>/ :Ack!<Space>

" tmux navigation integration
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-S-Left> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-S-Down> :TmuxNavigateDown<cr>
nnoremap <silent> <C-S-Up> :TmuxNavigateUp<cr>
nnoremap <silent> <C-S-Right> :TmuxNavigateRight<cr>
nnoremap <silent> <C-y> :TmuxNavigatePrevious<cr>

" vimux
nnoremap <Leader>p :VimuxPromptCommand<CR>
nnoremap <F4> :up<CR>:VimuxRunLastCommand<CR>
inoremap <F4> <ESC>:up<CR>:VimuxRunLastCommand<CR>

" fzf
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>r :History<CR>

" greplace
set grepprg=rg
let g:grep_cmd_opts = '--line-number --noheading'

" ultisnips configuration
let g:UltiSnipsExpandTrigger="<C-d>"
let g:UltiSnipsJumpForwardTrigger="<C-e>"
let g:UltiSnipsJumpBackwardTrigger="<C-r>"

" easy motion stuff
let g:EasyMotion_smartcase = 1
let g:EasyMotion_keys = 'ratidubpsolgen'
nmap <leader>n <Plug>(easymotion-s2)
nmap <leader>s <Plug>(easymotion-s1)
" TODO make delete/change till possible with easymotion
nmap f <Plug>(easymotion-fl)
nmap F <Plug>(easymotion-Fl)
nmap t <Plug>(easymotion-tl)
nmap T <Plug>(easymotion-Tl)

" Autoformat
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
nnoremap <leader>cf :Autoformat<CR> :up<CR>

" ALE (linting)
let g:ale_rust_cargo_use_clippy = executable('cargo-clippy')
let g:ale_virtualtext_cursor = 'current'
let g:ale_set_highlights = 0
" do not check on the fly
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_linters_ignore = { 'cpp': ['clangtidy'] }
let g:ale_echo_msg_format = '[%linter%] %code: %%s'

" C++ stuff
" don't indent namespace content and public/private/protected keywords
au FileType cpp set cino=N-s,g-s
nnoremap <leader>ch :up<CR> :TcSwitchHS<CR>
nnoremap <leader>cg :TcIncGuard<CR>
inoremap {<CR> {<CR>}<C-O>O
au FileType cpp set iskeyword-=:
" fix indent for switch case with {}
set cinoptions=l1

" Rust stuff
au FileType rust set iskeyword-=:
au FileType rust nmap <F8> :up<CR>:call VimuxRunCommand("clear; cargo fmt --check && cargo clippy --all-targets --all-features -- -D warnings")<CR>
au FileType rust nmap <F9> :up<CR>:call VimuxRunCommand("clear; cargo build --release")<CR>
au FileType rust nmap <F10> :up<CR>:call VimuxRunCommand("clear; cargo build")<CR>
au FileType rust nmap <F11> :up<CR>:call VimuxRunCommand("clear; cargo test")<CR>

" python stuff
" "else:" is the same as "else"
au FileType python set iskeyword-=:
au FileType python nmap <F8> :up<CR>:call VimuxRunCommand("clear; black --extend-exclude 'build\.py\|bootstrap\.py' --check . && poetry run pylint --recursive=y --ignore-patterns '(build\.py\|\.ycm_extra_conf\.py)' --ignore-paths 'build\|cross\|bootstrap\|core' .")<CR>
au FileType python nmap <F11> :up<CR>:call VimuxRunCommand("clear; poetry run pytest --cov=src --cov-report html:.coverage-html")<CR>

" Haskell stuff
au FileType haskell set iskeyword-=:

" Go stuff
au FileType go nmap <F9> :up<CR>:make<CR>
au FileType go nmap <F10> :up<CR>:GoBuild<CR>
au FileType go nmap t :GoDef<CR>

" Highlight maximum width for most filetypes
au FileType * highlight ColorColumn ctermbg=0
au FileType rust set cc=101
au FileType python set cc=101
au FileType kotlin set cc=101
au FileType elm set cc=101
au FileType cpp set cc=101
let blacklist = ['tex', 'vim', 'rust', 'python', 'kotlin', 'elm', 'cpp']
au FileType * if index(blacklist, &ft) < 0 | set cc=81

" execute local vimrc files as well
if filereadable(".vimrc.local")
    so .vimrc.local
endif
if filereadable(".vimrc.acro")
    so .vimrc.acro
endif

