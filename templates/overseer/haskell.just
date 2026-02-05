# @markers: *.cabal
dap_bin := ""
dap_args := "--mode cpu"

build:
    cabal build

run:
    cabal run

test:
    cabal test

repl:
    cabal repl
