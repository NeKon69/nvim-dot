# @markers: *.odin, ols.json
profile := "debug"
dap_bin := "app"
dap_args := "--mode cpu"

build:
    odin build . -out:app -{{profile}}

run: build
    ./app

check:
    odin check .
