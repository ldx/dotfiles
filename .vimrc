"
" .vimrc
"

runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

set nocompatible		" vim defaults
set encoding=utf-8
set ttyfast

set history=10000

if version >= 703
  set cm=blowfish	    " use Blowfish for encryption
endif

set directory=~/.tmp//,~/tmp//,/var/tmp//,/tmp//
set backupdir=~/.tmp//,~/tmp//,/var/tmp//,/tmp//
if version >= 703
  set undodir=~/.tmp//,~/tmp//,/var/tmp//,/tmp//
endif

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
if version >= 703
  set clipboard=unnamedplus
endif

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

if version >= 703
  set undofile
  "set colorcolumn=80
endif

" statusline
"set statusline=%F%m%r%h%w\ [buf\ #%n]\ [%Y/%{&ff}]\ [%l/%L[%p%%]\ %v]\ [\%03.3b/0x\%02.2B]
set laststatus=2

" remember certain things when we exit
"  ': number of previously edited files marks will be remembered for
"  ": number of lines to save each register
"  :: command-line history length
"  @: number of lines to save from the input line history
"  /: number of lines to save from the search history
"  %: save and restore the buffer list
"  n: where to save viminfo
set viminfo='1000,\"1000,:1000,@1000,/1000,%,n~/.viminfo

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

" ctags
set tags=./tags;/

" supertab
let g:SuperTabDefaultCompletionType = "context" "<c-x><c-u>

" clang_complete
"let g:clang_snippets = 1
"let g:clang_conceal_snippets = 1
" Disable auto popup, use <Tab> to autocomplete
let g:clang_complete_auto = 0
" Show clang errors in the quickfix window
let g:clang_complete_copen = 1
"let g:clang_use_library = 1
"let g:clang_library_path = /usr/lib/libclang.so.1

" statline
let g:statline_fugitive = 1

" syntastic
let g:syntastic_c_config_file = ".clang_complete"

" python-mode
let g:pymode_folding = 0
let g:pymode_options = 0
let g:pymode_lint_ignore = "E125"

" javacomplete
augroup jcomp
  autocmd!
  autocmd FileType java setlocal omnifunc=javacomplete#Complete
  autocmd FileType java call classpath#UpdateClasspath('<afile>:p')
augroup END

" markdown
augroup md
  autocmd FileType mkd setlocal tw=0
  autocmd FileType mkd setlocal nocursorline
augroup END
