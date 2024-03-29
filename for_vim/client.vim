if exists('g:autoloaded_oparen_client')
    finish
endif

let g:autoloaded_oparen_client=1


function! s:eval_submit(handle) abort
    if getline('.')[col('.')-1]=~# ')'
        let [start_l, start_c] = searchpairpos('(','',')','bn')
        let [end_l, end_c] = [line('.'),col('.')]
    else
        let [start_l, start_c] = searchpairpos('(','',')','bcn')
        let [end_l, end_c] = searchpairpos('(','',')','n')
    endif

    if start_l == end_l
        let res = getline(start_l)[start_c-1 : end_c-1]
    else
        let res = getline(start_l)[start_c-1 : -1] . "\n"
                    \ . join(getline(start_l + 1, end_l - 1), "\n")
                    \ . "\n" . getline(end_l)[0 : end_c-1]
    endif
    let current_file_name = expand("%")
    let line_num = line(".")
    let res = "(" . "eval " . res . " " . current_file_name . " " . line_num . ")"
    call ch_sendraw(a:handle, res)
    let output = ch_readraw(a:handle)
    echo output
endfunction

function! s:get_port_automatically() abort
    let current_dir =  expand("%:p:h")
    let tgt_filename = current_dir . "/" . ".oparen-port"
    if filereadable(tgt_filename)
        let port = readfile(tgt_filename)[0]
        return port
    else
        return 0
    endif
endfunction


let port = s:get_port_automatically()
let addr =  "127.0.0.1:" . port
let options = {'mode':'raw'}
let handle = ch_open(addr,options)
nnoremap <Plug>(eval) :<C-u>call <SID>eval_submit(handle)<CR>
nmap <silent> cpp <Plug>(eval)
