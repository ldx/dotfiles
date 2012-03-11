"
" .vimrc
"

runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

set nocompatible		" vim defaults
set encoding=utf-8
set ttyfast

set cm=blowfish	    " use Blowfish for encryption

set backspace=2			" backspacing over everything in insert mode
set autoindent			" always set autoindenting on
set syntax=c

set showcmd
set showmode
set wildmenu
set wildmode=list:longest

set cursorline			" show current line
set scrolloff=3     " scroll at 3 lines from top/bottom of screen
set visualbell			" do not beep

"set hlsearch			  " highlight search results
set showmatch			  " jump emacs style to matching bracket
set incsearch			  " show match for the pattern while typing
set ignorecase
set smartcase       " case-sensitive search if capitals present

set whichwrap=b,s,h,l	" these characters can move past end of line

" tabs
set smarttab
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" formatting
set tw=78
set wrap
set formatoptions=tcroqn
set cinoptions=(0,u0,U0
"set cinoptions=:0,l1,t0,g0	"linux kernel style

" clipboard
set clipboard=unnamedplus

" complete options (disable preview scratch window)
set completeopt=menu,menuone,longest

" limit popup menu height
set pumheight=15

" colors
set t_Co=256
set background=dark
colorscheme springforest

" show special characters
"set list
"set listchars=tab:▸\ ,eol:¬

if version >= 730
  set undofile
  set colorcolumn=80
endif

" statusline
"set statusline=%F%m%r%h%w\ [buf\ #%n]\ [%Y/%{&ff}]\ [%l/%L[%p%%]\ %v]\ [\%03.3b/0x\%02.2B]
set laststatus=2

" remember certain things when we exit
"  '100 :  marks will be remembered for up to 100 previously edited files
"  "1000:  will save up to 1000 lines for each register
"  :200 :  up to 200 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='100,\"1000,:200,%,n~/.viminfo

" switch syntax highlighting on
syntax on

" indenting
filetype indent plugin on

" highlight extra whitespace at end of line
highlight ExtraWhitespace ctermbg=1 guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" Arduino .pde files
autocmd BufWinEnter *.pde setf arduino
autocmd BufWinEnter *.ino setf arduino

" disable arrow keys
:map <left> <Nop>
:map <right> <Nop>
:map <up> <Nop>
:map <down> <Nop>

:imap <left> <Nop>
:imap <right> <Nop>
:imap <up> <Nop>
:imap <down> <Nop>

" map j to gj and k to gk, so line navigation ignores line wrap
nmap j gj
nmap k gk

" use ~/.vbuf as persistent buffer
vmap <C-y> :w! ~/.vbuf<CR>
nmap <C-p> :r ~/.vbuf<CR>

" restore cursor position
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup EN

" supertab
let g:SuperTabDefaultCompletionType = "context" "<c-x><c-u>

" clang_complete
let g:clang_snippets = 1
let g:clang_conceal_snippets = 1

" statline
let g:statline_fugitive = 1
