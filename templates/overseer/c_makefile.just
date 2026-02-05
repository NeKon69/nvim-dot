# @markers: Makefile
profile := "debug"
dap_bin := ""
dap_args := "--mode cpu"

build:
    make all PROFILE={{profile}}

run: build
    find . -maxdepth 1 -type f -executable -not -name "configure" -not -name "*.sh" -newer Makefile | head -n 1 | xargs -I {} {}

clean:
    make clean
