nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

let g:asyncomplete_auto_completeopt = 0

autocmd FileType python setlocal shiftwidth=4 softtabstop=4 expandtab
autocmd FileType javascript setlocal shiftwidth=2 softtabstop=2 expandtab

python3 << EOF
import vim
import os
import json
import subprocess

gopackagesdriver = ""
build_workspace_dir = ""

bazel_info = subprocess.run(["bazel", "info"], capture_output=True)
if bazel_info.returncode == 0:
    gopackagesdriver = "gopkgdriver"
    for line in bazel_info.stdout.splitlines():
        words = line.split()
        if len(words) == 2 and words[0] == b'workspace:':
            build_workspace_dir = words[1].decode()

gopls_cfg = json.loads("""{
	"build.env": {
        "GOPACKAGESDRIVER": "%s",
        "GOPACKAGESDRIVER_BAZEL_QUERY": "kind(go_binary, //...)",
        "GOPACKAGESDRIVER_BAZEL_TARGETS": "//...",
        "BUILD_WORKSPACE_DIRECTORY": "%s"
    },
    "build.directoryFilters": [
        "-bazel-bin",
        "-bazel-out",
        "-bazel-testlogs",
        "-bazel-mypkg"
    ]
}""" % (gopackagesdriver, build_workspace_dir))
EOF

let g:go_gopls_settings = py3eval("gopls_cfg")
