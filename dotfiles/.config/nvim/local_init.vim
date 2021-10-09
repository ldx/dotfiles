nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

let g:asyncomplete_auto_completeopt = 0

autocmd FileType python setlocal shiftwidth=4 softtabstop=4 expandtab
autocmd FileType javascript setlocal shiftwidth=2 softtabstop=2 expandtab

python3 << EOF
import vim
import json

gopls_cfg = json.loads("""{
	"build.env": {
        "GOPACKAGESDRIVER": "gopackagesdriver",
        "GOPACKAGESDRIVER_BAZEL_QUERY": "kind(go_binary, //...)",
        "GOPACKAGESDRIVER_BAZEL_TARGETS": "//..."
    }
}""")
EOF

let g:go_gopls_settings = py3eval("gopls_cfg")
