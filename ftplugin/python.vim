setlocal expandtab
setlocal colorcolumn=80
setlocal textwidth=79
" Enable comment continuation.
setlocal formatoptions+=cro
setlocal foldmethod=indent
setlocal foldminlines=10
setlocal textwidth=0

" Multi-line commenting and uncommenting.
vmap <buffer> <C-m> :s/^\(\s*\)/\1#/<Return>
vmap <buffer> <C-,> :s/^\(\s*\)#/\1/<Return>

" Use the AutoPythonImport tool.
map <buffer> <C-n> :call AutoPythonImport(expand("<cword>"))<Return>

" Change the line length for Python files based on configuration files.
function! ChangePythonLineLength() abort
    let l:conf = ale#path#FindNearestFile(bufnr(''), 'setup.cfg')
    " Reset settings back to defaults when configuration files are not found
    let l:line_length = 79

    if !empty(l:conf)
        for l:match in ale#util#GetMatches(
        \   readfile(l:conf),
        \   '\v^ *max-line-length *\= *(\d+)',
        \)
            let l:line_length = str2nr(l:match[1])
        endfor
    endif

    let &l:colorcolumn = l:line_length + 1
endfunction

call ChangePythonLineLength()

let b:ale_linters = ['flake8']
let b:ale_fixers = [
\   'remove_trailing_lines',
\   'isort',
\   'extra_ale_fixers#AutomaticallyFixJSONDiffOutput',
\   'ale#fixers#generic_python#BreakUpLongLines',
\   'autopep8',
\]
let b:ale_completion_excluded_words = ['and', 'or', 'if']

if expand('%:e') is# 'pyi'
    let b:ale_linters = ['mypy']
endif

map <buffer> <silent> <F9> :TestFile<CR>

let s:virtualenv = ale#python#FindVirtualenv(bufnr(''))

if !empty(s:virtualenv)
    if executable(s:virtualenv . '/bin/pytest')
        let g:test#python#runner = 'pytest'
        let g:test#python#pytest#executable =
        \   ale#path#CdString(ale#path#Dirname(s:virtualenv))
        \   . ale#Escape(s:virtualenv . '/bin/pytest')
    else
        let g:test#python#runner = 'djangotest'
        let g:test#python#djangotest#executable =
        \   ale#Escape(s:virtualenv . '/bin/python')
        \   . ' ' . ale#Escape(ale#path#Dirname(s:virtualenv) . '/manage.py') . ' test'
    endif
endif
