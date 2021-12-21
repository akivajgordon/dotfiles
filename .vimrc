call plug#begin('~/.vim/plugged')
Plug 'joshdick/onedark.vim'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
Plug 'psliwka/vim-smoothie'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jparise/vim-graphql'
Plug 'terryma/vim-expand-region'
Plug 'vim-test/vim-test'
Plug 'tpope/vim-surround'
Plug 'prabirshrestha/vim-lsp'

let test#javascript#ava#file_pattern = '\.test\.ts'
let test#javascript#ava#executable = 'npm test --'
call plug#end()

set number
set relativenumber
syntax on
let g:onedark_termcolors=256
colorscheme onedark
unlet g:terminal_ansi_colors
set re=0 " https://jameschambers.co.uk/vim-typescript-slow
let mapleader = ' '
set termwinsize=15x0 " https://vi.stackexchange.com/a/25753
set mouse=n

source $HOME/.vim/init/coc.nvim

" Bash language server: see https://github.com/bash-lsp/bash-language-server
if executable('bash-language-server')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'bash-language-server',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'bash-language-server start']},
        \ 'allowlist': ['sh'],
        \ })
endif
"-----------------

" https://shapeshed.com/vim-netrw/
" let g:netrw_banner = 0
" let g:netrw_liststyle = 3
" let g:netrw_browse_split = 4
" let g:netrw_altv = 1
" let g:netrw_winsize = 25
" augroup ProjectDrawer
"   autocmd!
"   autocmd VimEnter * :Vexplore
" augroup END
" 

nnoremap <C-p> :GFiles<Cr>
nnoremap <C-f> :Rg 
nnoremap <Leader>\t :botright terminal<CR>

" easily edit .vimrc
nnoremap <Leader>v :e $MYVIMRC<CR>
nnoremap <Leader>b :Buffers<CR>

" save a keystroke to move between windows
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Move a visual block of text easily
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Searching for next will center the screen so that the searched context is
" always in the same place
nnoremap n nzz
nnoremap N Nzz

nnoremap <Leader>tl :TestLast<CR>
nnoremap <Leader>ts :TestSuite<CR>
nnoremap <Leader>tn :TestNearest<CR>

set splitbelow
set splitright

" -------------
" Auto refresh for files changed outside of Vim. See https://unix.stackexchange.com/a/383044/146423
"
" Triger `autoread` when files changes on disk
" https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
" https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
    autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
            \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif

" Notification after file change
" https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
autocmd FileChangedShellPost *
  \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

" -------------
