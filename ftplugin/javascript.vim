setlocal expandtab
setlocal cc=80

if has('gui_running')
    setlocal spell
endif

" Map Ctrl+R to alignment.
vmap <buffer> <C-r> :Align = :<Return>

function! b:AutoFormatJavaScript()
    " Save the current position.
    let l:line_number=line('.')
    let l:column_number=col('.')

    " Run js-beautify on every line.
    silent 0,$!js-beautify -

    " Write the buffer to a temporary file.
    silent :w %.eslintfix

    try
        " Run eslint on the file.
        silent !eslint --fix %.eslintfix
        " Replace the current buffer with the file we fixed.
        silent 0,$!cat %.eslintfix
    finally
        silent !rm -f %.eslintfix
    endtry

    " Jump back to the line number and cursor before, which might be a
    " little off.
    call cursor(l:line_number, l:column_number)

    echo "Re-formatted code"
endfunction

map <buffer> <F8> :call b:AutoFormatJavaScript()<Return>
