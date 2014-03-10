"
" .vimrc
"

runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

set nocompatible		" vim defaults
set encoding=utf-8
set ttyfast

set history=10000

set hidden

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

"set cursorline			" show current line
set scrolloff=3     " scroll at 3 lines from top/bottom of screen
set visualbell			" do not beep

set hlsearch			  " highlight search results
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
  "set clipboard=unnamedplus
  set clipboard=unnamed
endif

" mouse
"set mouse=a

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
  highlight ColorColumn ctermbg=magenta
  call matchadd('ColorColumn', '\%81v', 100)
endif

" better match highlight
highlight WhiteOnRed ctermbg=red ctermfg=white

function! HLNext (blinktime)
    let [bufnum, lnum, col, off] = getpos('.')
    let matchlen = strlen(matchstr(strpart(getline('.'),col-1),@/))
    let target_pat = '\c\%#'.@/
    let ring = matchadd('WhiteOnRed', target_pat, 101)
    redraw
    exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
    call matchdelete(ring)
    redraw
    exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
    let ring = matchadd('WhiteOnRed', target_pat, 101)
    redraw
    exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
    call matchdelete(ring)
    redraw
endfunction

nnoremap <silent> n   n:call HLNext(0.1)<cr>
nnoremap <silent> N   N:call HLNext(0.1)<cr>

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

" leader key
:let mapleader=","

" switch syntax highlighting on
syntax on

" indenting
filetype indent plugin on

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

" <Ctrl-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <C-l> :nohl<CR><C-l>

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

" git commit messages
au FileType gitcommit set tw=72

" ctags
set tags=./tags;/

" disable certain plugins if python versions is old
let pyversion = 0
:py << EOF
import sys
import vim
vim.command("let pyversion = %d" % (sys.hexversion))
EOF

if pyversion < 0x02050000
  let g:pymode = 0
  let g:jedi#auto_initialization = 0
endif

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
let g:clang_library_path = "/usr/lib/llvm-3.3/lib"

" statline
let g:statline_fugitive = 1

" syntastic
let g:syntastic_c_config_file = ".clang_complete"

" python-mode
let g:pymode_folding = 0
let g:pymode_options = 0
let g:pymode_lint_ignore = "E125"
let g:pymode_rope = 0 " disable, it can freeze Vim for minutes

" jedi
let g:jedi#popup_on_dot = 0

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

" puppet
augroup puppet
  autocmd FileType puppet setlocal equalprg=puppet-tidy
  autocmd FileType puppet :map <Leader>t :Tabularize /=>/l1<CR>
augroup END

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

" NERDTree
map <C-n> :NERDTreeToggle<CR>

" Make sure gitgutter signs are shown.
"autocmd CursorHold * exe "silent! GitGutterSignsEnable"
"autocmd CursorHoldI * exe "silent! GitGutterSignsEnable"
"autocmd CursorMoved * exe "silent! GitGutterSignsEnable"

" Always show gutter.
"autocmd BufEnter * sign define dummy
"autocmd BufEnter * execute 'sign place 9999 line=1 name=dummy buffer=' . bufnr('')

" YCM clears up all signs in gutter, which messes up other plugins.
let g:ycm_show_diagnostics_ui=0
let g:ycm_enable_diagnostic_signs=0
let g:ycm_confirm_extra_conf=0
